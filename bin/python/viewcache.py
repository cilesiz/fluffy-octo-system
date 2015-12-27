#!/usr/bin/env python

"""Memcached utilities for HSSN."""

import telnetlib
import optparse
import re
import os
import sys
import pprint

# from http://mail.python.org/pipermail/python-list/2008-August/503423.html

_abbrevs = [
    (1<<50L, ' Pb'),
    (1<<40L, ' Tb'),
    (1<<30L, ' Gb'),
    (1<<20L, ' Mb'),
    (1<<10L, ' Kb'),
    (1, ' b')
    ]

def bytestr(size, precision=1):
    """Return a string representing the greek/metric suffix of a size"""
    if isinstance(size, basestring): size = int(size)
    if size==1:
        return '1 byte'
    for factor, suffix in _abbrevs:
        if size >= factor:
            break

    float_string_split = `size/float(factor)`.split('.')
    integer_part = float_string_split[0]
    decimal_part = float_string_split[1]
    if int(decimal_part[0:precision]):
        float_string = '.'.join([integer_part, decimal_part[0:precision]])
    else:
        float_string = integer_part
    return float_string + suffix

def humantime(seconds):
    if not isinstance(seconds, (int, long)):
        seconds = int(seconds)
    minutes = (seconds // 60)
    seconds = seconds % 60
    hours = (minutes // 60)
    minutes = minutes % 60
    days  = (hours // 24)
    hours = hours % 24
    weeks = (days // 7)
    if weeks:
        return '(%dwk) %dd %02d:%02d:%02d' % (weeks, days, hours, minutes, seconds)
    elif days:
        return '%dd %02d:%02d:%02d' % (days, hours, minutes, seconds)
    elif hours:
        return '%02d:%02d:%02d' % (hours, minutes, seconds)
    elif minutes:
        return '%02d:%02d' % (minutes, seconds)
    else:
        return '%02ds' % seconds

class _fdict(object):
    """Mixin to fake a dictionary using a real dictionary whose name is _real."""
    def __getitem__(self, item):
        return getattr(self, self._real)[item]
    def __iter__(self):
        return getattr(self, self._real).iterkeys()
    def iterkeys(self): return getattr(self, self._real).iterkeys()
    def iteritems(self): return getattr(self, self._real).iteritems()
    def keys(self): return getattr(self, self._real).keys()
    def items(self): return getattr(self, self._real).items()
    def __repr__(self):
        return '%r' % (getattr(self, self._real))

class MemcacheStats(object):
    def __init__(self, lines):
        self.lines = [l.strip() for l in lines.split('\n')]
        self._stats = {}
        for line in self.lines:
            if not line.startswith("STAT"): continue
            parts = line.split()
            self._stats[parts[1]] = parts[2]
        for k,v in self._stats.items():
            setattr(self, k, v)

class MemcacheSlabs(_fdict):
    """A class that acts as a dictionary of memcached slabs."""
    slab_re = re.compile(r'^STAT items:(\d+):(\w+) (\d+)')
    _real = 'slabs'
    def __init__(self, lines):
        self.lines = [l.strip() for l in lines.split('\n')]
        self.slabs = {}
        for l in self.lines:
            m = self.slab_re.match(l)
            if not m: continue
            g = m.groups()
            self.slabs.setdefault(g[0], {})[g[1]] = g[2]

class MemcacheSlabInfo(MemcacheSlabs):
    """A dictionary of slab info."""
    slab_re = re.compile('STAT (\d+):([_\w]+) (\d+)')

class MemcacheKeys(object):
    def __init__(self, lines):
        self.lines = [l.strip() for l in lines.split('\n')]
        self.keys = []
        for l in self.lines:
            s = l.split()
            if len(s) < 2: continue
            self.keys.append(s[1])
    def __iter__(self):
        return iter(self.keys)

def getstats(tn):
    tn.read_eager()
    tn.write("stats\r\n")
    return MemcacheStats(tn.read_until("END", 1))

def getslabs(tn):
    tn.read_eager()
    tn.write('stats items\r\n')
    return MemcacheSlabs(tn.read_until('END', 1))

def getslabinfo(tn):
    tn.read_eager()
    tn.write('stats slabs\r\n')
    return MemcacheSlabInfo(tn.read_until('END', 1))

def getkeys(tn):
    tn.read_eager()
    slabs = getslabs(tn)
    ids = [str(s) for s in sorted([int(s) for s in slabs])]
    keys = []
    for slab in slabs:
        s = slabs[slab]
        num = int(s['number'])
        tn.write('stats cachedump %s %s\r\n' % (slab, num))
        keys += list(MemcacheKeys(tn.read_until('END', 1)))
    return keys

def printstats(stats):
    import time
    # strip the day of the week off of ctime
    fmt = lambda x: ' '.join(time.ctime(x).split(' ')[1:])
    print "Memcache v%(version)s, %(pointer_size)sbit, usr/sys: %(rusage_user)s/%(rusage_system)s" % stats._stats,
    print " PID: %(pid)s" % stats._stats
    stats._stats['ctime'] = fmt(float(stats.time))
    stats._stats['upsince'] = fmt(float(stats.time) - float(stats.uptime))
    print "   Time: %(ctime)s uptime: %(uptime)s (up since: %(upsince)s)" % stats._stats
    print "   Connections: %(curr_connections)s, %(total_connections)s, %(connection_structures)s (current, total, structures)" % stats._stats
    print "   Usage: %s current (%s total), %s" % (stats.curr_items, stats.total_items, bytestr(stats.bytes))
    hits = int(stats.get_hits)
    misses = int(stats.get_misses)
    total = hits + misses
    ratio = float(hits) / float(total)
    stats._stats['hit_ratio'] = '%0.2f' % (ratio * 100.0)
    print "   Cache: hits/misses: %(get_hits)s/%(get_misses)s, %(evictions)s evictions, %(hit_ratio)s%% hit ratio" % stats._stats
    seconds = float(stats.uptime)
    gps = '%0.2f' % (total / seconds)
    hps = '%0.2f' % (hits / seconds)
    mps = '%0.2f' % (misses / seconds)
    print "   Lifetime stats:  %s gets/sec,  %s/%s hits/misses per sec" % (gps, hps, mps)

def printslabs(slabs, infos):
    """Takes MemcacheSlabs and prints them out."""
    ids = [str(s) for s in sorted([int(s) for s in slabs])]
    print '  ' + 'slab'.ljust(6) + 'size'.ljust(10) + 'items'.ljust(10) + 'maxage'
    for id in ids:
        s = slabs[id]
        i = infos[id]
        print '  ' + str(id).ljust(6) + bytestr(i.get('chunk_size', '0')).ljust(10) + s.get('number', '?').ljust(10) + humantime(s.get('age', '0'))

def viewstats(host, ports):
    print "Viewing stats on '%s' ports '%s'" % (host, ports)
    for port in ports:
        tn = telnetlib.Telnet(host, port)
        printstats(getstats(tn))
        tn.close()

def viewkeys(host, ports, match, comp=lambda x,y: y in x):
    print "Viewing keys on '%s' ports '%s' (matching %s)" % (host, ports, match)
    for port in ports:
        tn = telnetlib.Telnet(host, port)
        keys = getkeys(tn)
        keys = [k for k in keys if comp(k, match)]
        tn.close()
        print "%d KEYS: %s:%s" % (len(keys), host, port)
        for k in keys:
            print "  %s" % k

def delkeys(host, ports, match, comp=lambda x,y: y in x):
    print "Deleting keys on '%s' ports '%s' (matching %s)" % (host, ports, match)
    for port in ports:
        tn = telnetlib.Telnet(host, port)
        keys = getkeys(tn)
        keys = [k for k in keys if comp(k, match)]
        print "  Deleting %d keys: %s:%s" % (len(keys), host, port)
        for i,k in enumerate(keys):
            tn.write('delete %s\r\n' % k)
            tn.expect(['DELETED', 'NOT_FOUND'], 1)
            print '\rdeleted ' + str(i),
        #tn.read_until('DELETED', 1)
        tn.close()

def viewobjs(host, port, keys):
    if 'DJANGO_SETTINGS_MODULE' not in os.environ:
        os.environ['DJANGO_SETTINGS_MODULE'] = 'hssn.settings'
    try:
        from django.conf import settings
        settings.CACHE_BACKEND = 'memcached://%s:%s/' % (host, port)
        #print settings.CACHE_BACKEND
        from django.core.cache import cache
    except:
        print '--view requires a functioning django install'
        raise
        sys.exit(-1)
    for key in keys:
        val = cache.get(key)
        print '%s: %s' % (key, pprint.pformat(val))

def viewslabs(host, ports):
    print "Viewing slabs on '%s' ports '%s'" % (host, ports)
    for port in ports:
        print "SLAB: %s:%s" % (host, port)
        tn = telnetlib.Telnet(host, port)
        slabs = getslabs(tn)
        infos = getslabinfo(tn)
        printslabs(slabs, infos)
        tn.close()

def flushall(host, ports):
    print "Flushing all keys on '%s' ports '%s'" % (host, ports)
    for port in ports:
        tn = telnetlib.Telnet(host, port)
        tn.read_eager()
        tn.write('flush_all\r\n')
        tn.expect(['OK'], 1)
        tn.close()

def main():
    parser = optparse.OptionParser()
    parser.add_option('-s', '--slabs', action='store_true', help='view slabs')
    parser.add_option('-k', '--keys', help='view keys with prefix KEYS')
    parser.add_option('-d', '--delkeys', help='delete keys with prefix DELKEYS')
    parser.add_option('-v', '--view', help='view objects with key VIEW')
    parser.add_option('', '--flushall', action='store_true', help='flush all objects from the servers')
    opts, args = parser.parse_args()
    host = args[0]
    ports = args[1:]
    if opts.slabs and opts.keys:
        import sys
        print 'Cannot use -s, -k'
        sys.exit()
    elif opts.flushall:
        flushall(host, ports)
    elif opts.view:
        viewobjs(host, ports[0], opts.view.split(','))
    elif not opts.slabs and opts.keys == None and opts.delkeys == None:
        viewstats(host, ports)
    elif opts.slabs:
        viewslabs(host, ports)
    elif opts.keys != None:
        viewkeys(host, ports, opts.keys)
    elif opts.delkeys != None:
        delkeys(host, ports, opts.delkeys)

if __name__ == '__main__':
    try:
        main()
    except IOError:
        pass

