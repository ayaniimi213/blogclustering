#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require "kconv"
require 'TFIDF'

class WeightedTFIDF < TFIDF

#  def initialize
#    super()
#  end

  def loadDic(filename)
    # 辞書の内容を読み込む

    @weight =  2.0 # 重み一定

    createImportant_table(@db)

    file = open(filename)
    while word = file.gets do
      word.chomp!
      kw_id = setKeywordId(word)
#      print kw_id, word, "\n"
      storeImportant(kw_id, @weight)
    end
    file.close

  end

  def storeImportant(kw_id, weight)
    sql = <<SQL
insert into important(kw_id, weight)
select kw_id, 1.0 from df
SQL
    db.execute(sql)

    sql = "update into important(kw_id, weight) values(:kw_id, :weight)"
    @db.execute(sql, :kw_id => kw_id, :weight => weight)
#    print kw_id, ",", weight, "\n"
  end

  def createImportant_table(db)
#    db.execute("drop table important")
    sql = <<SQL
create table important (
 kw_id INTEGER PRIMARY KEY,
 weight real
);
SQL
    
    db.execute(sql)
  end


  def createWTFIDF_table(db)
    sql = <<SQL
create table wtfidf (
 doc_id INTEGER,
 kw_id INTEGER,
 score real
);
SQL
    
    db.execute(sql)
  end

  def setWeightedTFIDF
    createWTFIDF_table(@db)

    @db.transaction do
      sql = <<SQL


SQL

      sql = "insert into wtfidf(kw_id, score) select kw_id, score from tfidf"
      @db.execute(sql)
      sql = "update wtfidf set score = (select (tfidf.score * important.weight) from tfidf, important where tfidf.kw_id = important.kw_id)"
      @db.execute(sql)

    end

  end

  def showWTFIDF
    print "show WTFIDF\n"
    @db.execute("select keywords.word, wtfidf.score from keywords, wtfidf where keywords.kw_id = wtfidf.kw_id"){|keyword, score|
      print keyword, ",", score, "\n"
    }
  end

  def showImportant
    print "show Important\n"
    @db.execute("select kw_id, weight from important"){|kw_id, weight|
      print kw_id, ",", weight, "\n"
    }
  end

  
  def outputTFIDF
    words = @db.query("select word from keywords order by kw_id")
    print "DocID", ","
    words.each{|word|
      print word, ","
    }
    print "\n"
    
    docs = @db.query("select doc_id, uri from docs")
    
    sql = <<SQL
select kw_id, 
case
  when doc_id IS NULL THEN 0.0
  ELSE score
END
from 
(select wtfidf.kw_id, wtfidf.score, bodytext.doc_id
from wtfidf LEFT OUTER JOIN (select DISTINCT kw_id, doc_id from bodytext where doc_id = :doc_id) as bodytext
on wtfidf.kw_id = bodytext.kw_id)
ORDER BY kw_id;
SQL
  
    docs.each{|doc_id, uri|
      print doc_id, ","
      print uri, ","
      
      @db.execute(sql, :doc_id => doc_id){|kw_id, score|
        #    print kw_id, ","
        print score, ","
      }
      print "\n"
    }
  end

end

if $0 == __FILE__

  tfidf = WeightedTFIDF.new()

  uri = "http://url1"
  text = "今日もしないとね。今日もしないとね。昨日、昨日。"
  print text, "\n"
  tfidf.store(uri, text)
  
  uri = "http://url2"
  text = "今日もしないとね。明日。"
  print text, "\n"
  tfidf.store(uri, text)
  
  tfidf.showBodyText()
  tfidf.showTF()
  tfidf.showDF()

  tfidf.loadDic("test.dic")
  tfidf.showImportant()
  tfidf.setWeightedTFIDF()

  tfidf.showTFIDF()
  tfidf.showWTFIDF()

  tfidf.outputTFIDF()

#  tfidf.closeDB()

end
