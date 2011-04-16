#!/usr/bin/env ruby
# count words

count = Hash.new(0)

## count words
while line = gets
  words = line.split
  words.each{|word|
    count[word] += 1
  }
end

##output result
count.sort{|a,b|
  a[1] <=> b[1]
}.each{|key, value|
  print "#{key}: #{value}\n"
}
