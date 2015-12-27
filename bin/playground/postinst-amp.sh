#!/bin/sh
. /etc/bashrc
DATADIR="/master/amp/etc/sysconfig/files/xmlfeed"
# Generate cfengine key for this client (and copy to server)
ssh root@$ip_address "mkdir -p /var/cfengine/ppkeys"
ssh root@$ip_address "/usr/local/sbin/cfkey"
#MY_IP=`ifconfig eth0 | sed -n 's/.*inet addr:\([^ ]*\).*/\1/p'`
scp /var/cfengine/ppkeys/localhost.pub root@e-log-01.admarketplace.net:/var/cfengine/ppkeys/root-$ip_address.pub

# set up tomcat

#DB5="72.52.211.236"
#sed "s/72.52.211.xxx/$DB5/g" /home/tomcat6/apache-tomcat-6.0.18/conf/server.xml > /home/tomcat6/apache-tomcat-6.0.18/conf/server.xml2 && mv -f /home/tomcat6/apache-tomcat-6.0.18/conf/server.xml2 /home/tomcat6/apache-tomcat-6.0.18/conf/server.xml

#sed "s/72.52.21x.xxx/$MY_IP/g" /home/tomcat6/apache-tomcat-6.0.18/bin/catalina.sh > /home/tomcat6/apache-tomcat-6.0.18/bin/catalina.sh2 && mv -f /home/tomcat6/apache-tomcat-6.0.18/bin/catalina.sh2 /home/tomcat6/apache-tomcat-6.0.18/bin/catalina.sh
scp root@$ip_address   

cd /home/tomcat6/apache-tomcat-6.0.18/webapps/xmlamp/WEB-INF/build && /home/tomcat6/apache-ant-1.7.1/bin/ant clean && /home/tomcat6/apache-ant-1.7.1/bin/ant compile

chkconfig --level 235 tomcat on

# set up snmpd

sed "s/72.52.21x.xxx/$MY_IP/g" /etc/snmp/snmpd.conf > /etc/snmp/snmpd.conf2 && mv -f /etc/snmp/snmpd.conf2 /etc/snmp/snmpd.conf
chkconfig --level 235 snmpd on
# turn on cfengine
sed 's/OFF//g' /var/spool/cron/root > /var/spool/cron/root2 && mv -f /var/spool/cron/root2 /var/spool/cron/root
chkconfig --level 235 cfenvd on
chkconfig --level 235 cfexecd on
chkconfig --level 235 cfservd on
# Finally, run cfengine to perform all other configuration tasks
/usr/local/sbin/cfagent
# All done (prevent this script from running again)
rm -f /etc/rc.d/rc3.d/S99prepare_system

#!/usr/bin/bash
# taken from the book "sage" starting at page 9
# this script requires that you have cfegine already installed

# as root...
# create the basic structure of the cfengine work directory tree
target=$1.internal.upoc.com
scp root@$target "mkdir /var/cfengine"
scp root@$target "mkdir /var/cfengine/bin"
scp root@$target "mkdir /var/cfengine/inputs"
scp /Documentation/cfengine
bwprefix="/Documentation/cfengine/bin"
bootprefix="/Documenation/cfengine/cfagent.conf"
cp $bwprefix/cfagent /var/cfengine/bin
cp $bwprefix/cfexecd /var/cfengine/bin
cp $bwprefix/cfservd /var/cfengine/bin
chown -R root:0 /var/cfengine
chmod -R 700 /var/cfengine

# create a trivial agent policy

# see in this same dir triv/cfagent.conf
while true; do for i in 1 2 3 4 5;  do f=3; if [ $i == 3 ]; then echo "$f";fi; done;break; done

dynamic files for templates

snmpd.conf (jmx)
server.xml based on class of server

databases

db2:72.52.211.239
db3:72.52.211.238
db4:72.52.211.237
db5: 72.52.211.236
db9:72.52.211.72
db12:72.52.211.52



snmpd.conf

rocommunity ampase
disk / 
disk /home 
disk /var 
disk /backup 
disk /usr
disk /usr/local
disk /tmp
proxy -v 2c -c ampase 72.52.21x.xx:1161 .1.3.6.1.4.1.42.2.145.3.163.1

catalina.sh

JAVA_OPTS="-Dcom.sun.management.snmp.acl=false -Dcom.sun.management.jmxremote.port=9003 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.snmp.port=1161 -Dcom.sun.management.snmp.interface=72.52.21x.xxs"
ulimit -n 100000
CATALINA_OPTS="-server -Xmx512m"
CATALINA_HOME="/tomcat"
CATALINA_BASE="/tomcat"


nrpe.conf

post script 

ant clean && ant compile
sed filters for snmpd.conf and catalina.sh
and server.xml specific to the class of server

xmlfeedclass1="xml01 xml02 xml03 xml04 xml05"
xmlfeedclass2="xml06 xml07 xml08 xml09 xml10 xml11 xml12"
xmlfeedclass3="xml13 xml14 xml15"

xmlfeedclass1db="72.52.211.236 72.52.211.72 72.52.211.52"
xmlfeedclass2db="72.52.211.238 72.52.211.72 72.52.211.52"
xmlfeedclass3db="72.52.211.237 72.52.211.72 72.52.211.52 "

xml1dbs = 72.52.211.236 

chkconfig --level 235 tomcat on
chkconfig --level 235 snmpd on
cd /home/tomcat6/apache-tomcat-6.0.18/webapps/xmlamp/WEB-INF/build && ant clean && ant compile

ask mike where these servers should be connecting too (mysql)

cfagent

to do: write sysimager deployment script
#!/bin/bash
host=$1

ssh root@$host.internal.upoc.com "mkdir -p /var/cfengine/inputs"
ssh root@$host.internal.upoc.com "mkdir /var/cfengine/bin && cp /usr/local/sbin/cf* /var/cfengine/bin"
scp /Documentation/cfengine/solaris10/bootstrap/cfagent.conf root@$host.internal.upoc.com:/var/cfengine/inputs
scp /Documentation/cfengine/solaris10/bootstrap/cfservd.conf root@$host.internal.upoc.com:/var/cfengine/inputs
ssh root@$host.internal.upoc.com "/var/cfengine/bin/cfservd && /var/cfengine/bin/cfenvd && /usr/local/sbin/cfkey && /var/cfengine/bin/cfagent -v"
#cfengine-2.2.3-sol10-sparc-local.gz  dist-cfengine-binaries.sh       libgcc-3.4.6-sol10-sparc-local.gz
#db-4.2.52.NC-sol10-sparc-local.gz    gcc-3.4.6-sol10-sparc-local.gz  openssl-0.9.8g-sol10-sparc-local.gz