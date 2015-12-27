#!/usr/bin/env ruby

unless ARGV[0]
	puts "You need to include a password to test, dick"
	puts "Usage ruby password.rb mySuperSecretPassword"
	exit
end

password = ARGV[0]
word = password.split(//)
letters = Hash.new(0.0)
set_size = 96

word.each do |i|
	letters[i] += 1.0
end

letters.keys.each do |j|
	letters[j] /= word.length
end

entropy = -1 * letters.keys.inject(0.to_f) do |sum, k|
	sum + (letters[k] * (Math.log(letters[k])/Math.log(2.to_f)))
end

combinations = 96 ** password.length

days = combinations.to_f / (100000000 * 86400)

years = days / 365

puts "\nThe entropy value is: #{entropy}"
puts "\nAnd it will take ~ #{days <365 ? "#{days.to_i } days" : "#{years.to_i} years"} to brute force the password" 