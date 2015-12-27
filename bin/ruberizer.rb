#!/usr/bin/env ruby -w
#
#
path = ARGV[0]
fail "specify filename to create" unless path
#
#
File.open(path, "w") { |f| f.puts "#/Users/ross/.rvm/rubies/ruby-2.0.0-p247/bin/ruby -w" }
File.chmod(0755, path)
system "open", path
