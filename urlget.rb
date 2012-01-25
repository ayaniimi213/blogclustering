#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

if ( RUBY_VERSION < "1.9" )
  require 'mwextractcontenttest'
  require 'GetFactory'
#  require 'MeCab' # need install MeCab and see mecab document
  require 'easymecab'
  require 'WeightedTFIDF'
else
  require_relative 'mwextractcontenttest'
  require_relative 'GetFactory'
#  require_relative 'MeCab' # need install MeCab and see mecab document
  require_relative 'easymecab'
  require_relative 'WeightedTFIDF'
end

#usage:
# ruby urlget.rb blog_500.txt

# 深さ
depth    = "1"
# 同一サイトのみ探索
sameSite = "1"


file = open(ARGV[0])

#tfidf = TFIDF.new()
tfidf = WeightedTFIDF.new()
tfidf.loadDic(ARGV[1])

while base = file.gets do
  base.chomp!
  p base
  dailyUrls = Array.new

  factory = GetFactory.new()
  get = factory.create(base)

  dailyUrls =  get.extract

  dailyUrls.each{|url|
    mwTest = MwExtractCountentTest.new(sameSite.to_i)
    mwTest.test(url, depth.to_i)
#    p mwTest.getBody()
#    m = MeCab.new("")
#    print m.parse( mwTest.getBody() )
    tfidf.store(url, mwTest.getBody() )
  }
end

tfidf.showTFIDF()
tfidf.outputTFIDF()

file.close

