#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require "kconv"
require 'TFIDF'

class WeightedTFIDF < TFIDF

  def initialize()
    @weight = Hash.new
    super()
  end

  def loadDic(filename)
    # 辞書の内容を読み込む
    # Hashに読み込む？

    file = open(filename)
    while word = file.gets do
      word.chomp!
     @weight.store(word, 2.0) # 重み一定
    end
    file.close
  end

  def setWeightedTFIDF
    sql = "create table wtfidf as select * from tfidf"
    reslut = @db.query(sql)

    sql = "update score * :weight from wtfidf where kw_id = (select kw_id from keywords where word = :word)"
    @weight.each{|word, w|
      @db.query(sql, :weight => w, :word => word)
    }

  end

  
  def getTFIDF(kw_id)
    score = super(kw_id)
    
    sql = "select word from keywords"
    result = @db.query(sql)
    result.each{|keyword|
#      print "keyword:", keyword, "\n"
      @weight.each{|word, w|
#      print "word:", word, "\n"
#        if word == keyword then
#        if keyword =~ /word/o then
        if keyword =~ /今日/ then
          print "haha\n"
          score = score * @weight[keyword]
        else
          score = score
        end
      }
    }

    return score
  end

end

if $0 == __FILE__
  uri = "http://hoehoe/poepoe/"
  text = "今日もしないとね。今日もしないとね。"
  
  print text, "\n"
  tfidf = WeightedTFIDF.new()
  tfidf.loadDic("test.dic")

  tfidf.store(uri, text)
  
  uri = "http://hoehoe/poepoe/"
  text = "今日もしないとね。"
  
  print text, "\n"
  
  tfidf.store(uri, text)
  
  tfidf.outputTFIDF()

#  tfidf.closeDB()

end
