#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

if ( RUBY_VERSION < "1.9" )
  require 'mymwextractcontenttest'
  require 'GetFactory'
#  require 'MeCab' # need install MeCab and see mecab document
  require 'easymecab'
  require 'WeightedTFIDF'
else
  require_relative 'mymwextractcontenttest'
  require_relative 'GetFactory'
#  require_relative 'MeCab' # need install MeCab and see mecab document
  require_relative 'easymecab'
  require_relative 'WeightedTFIDF'
end

#usage:
# ruby urlget.rb blog_500.txt tfidf.sqlite
# ruby urlget.rb blog_500.txt tfidf.sqlite keyword.txt

# 深さ
depth    = "1"
# 同一サイトのみ探索
sameSite = "1"

if ARGV.size == 2
  listfile = ARGV[0]
  dbfile = ARGV[1]
elsif ARGV.size == 3
  listfile = ARGV[0]
  dbfile = ARGV[1]
  dicfile = ARGV[2]
else
  print "usage:\n"
  print " ruby urlget.rb blog_500.txt tfidf.sqlite\n"
  print " ruby urlget.rb blog_500.txt tfidf.sqlite keyword.txt\n"
end

file = open(listfile)

if dicfile == nil
  tfidf = TFIDF.new(dbfile)
else
  tfidf = WeightedTFIDF.new(dbfile)
end

while base = file.gets do
  base.chomp!
  p base
  dailyUrls = Array.new

  factory = GetFactory.new()
  get = factory.create(base)

  dailyUrls =  get.extract

  dailyUrls.each{|url|
    mwTest = MyMwExtractCountentTest.new(sameSite.to_i)
    mwTest.test(url, depth.to_i)
#    p mwTest.getBody()
#    m = MeCab.new("")
#    print m.parse( mwTest.getBody() )
    tfidf.store(url, mwTest.getBody() )
  }
end

if dicfile != nil
  tfidf.loadDic(dicfile, 2.0)
end

# tfidf.showTFIDF()
tfidf.outputTFIDF()

file.close

