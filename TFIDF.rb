#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'rubygems'
require 'sqlite3'
#  require 'MeCab' # need install MeCab and see mecab document

require 'easymecab'
require 'InitDB'

class TFIDF
  def initialize
    #sqliteまわりの設定
    dbfile = "tfidf.sqlite"
    initdb = InitDB.new(dbfile) unless FileTest.file?(dbfile)
    @db = SQLite3::Database.new(dbfile)
#    @tfidf = Hash.new
  end
  
  def closeDB
    @db.close
  end

  def store(uri, text)
    doc_id = setDocId(uri)
    words = wakati(text)
    words.each{|word|
      # 原型を取りたい
      next if word["feature"] == "。" # 多分、分かち書きですでに捨てている
      next if word["feature"] == "、" # 多分、分かち書きですでに捨てている
      next if word["feature"] == "." # 多分、分かち書きですでに捨てている
      next if word["feature"] == "," # 多分、分かち書きですでに捨てている
      next unless word["wordclass"] =~ /名詞/
      kw_id = setKeywordId(word["feature"])
#      print kw_id, word["feature"], "\n"
      storeTF(kw_id)
      storeDocBody(doc_id, kw_id)
    }
    
  end
  
  def wakati(text) # 分かち書き
    m = MeCab.new("")
    return m.parse( text )
  end
  

  def setDocId(uri)
    # DocIDを割り付ける
    doc_id = 0
    @db.transaction do
      sql = "insert into docs(uri) values(:uri)"
      @db.execute(sql, :uri => uri)
      sql = "select LAST_INSERT_ROWID()"
      doc_id = @db.get_first_value(sql)
    end

    return doc_id
  end
  
  def setKeywordId(keyword)
    # KeywordIDを割り付ける
    kw_id = 0
    @db.transaction do
      sql = "select kw_id from keywords where word = :word"
      kw_id = @db.get_first_value(sql, :word => keyword)
      if kw_id == nil then
        sql = "insert into keywords(word) values(:word)"
        @db.execute(sql, :word => keyword)
        sql = "select LAST_INSERT_ROWID()"
        kw_id = @db.get_first_value(sql)
       end
    end

    return kw_id
  end
  
  def storeDocBody(doc_id, kw_id)
    @db.transaction do
      sql = "insert into bodytext values(:doc_id, :kw_id)"
      @db.execute(sql, :doc_id => doc_id, :kw_id => kw_id)
    end
  end
  
  def storeTF(kw_id)
    @db.transaction do
      sql = "select count from tf where kw_id = :kw_id"
      count = @db.get_first_value(sql, :kw_id => kw_id)
      if count == nil then
        count = 1
        sql = "insert into tf(kw_id, count) values(:kw_id, :count)"
        @db.execute(sql, :kw_id => kw_id, :count => count)
      else
        count = count + 1
        sql = "update tf set count = :count where kw_id = :kw_id"
        @db.execute(sql, :kw_id => kw_id, :count => count)
      end
#      print kw_id, ",", count, "\n"
    end
  end
  
  def showTFIDF
    print "show TFIDF\n"
    @db.execute("select keywords.word, total(tfidf.score) from keywords, tfidf where keywords.kw_id = tfidf.kw_id group by kw_id order by tfidf.score"){|keyword, score|
      print keyword, ",", score, "\n"
    }
  end

  def showDF
    print "show DF\n"
    @db.execute("select * from df"){|doc_id, count|
      print doc_id, ",", count, "\n"
    }
  end

  def showBodyText
    print "show bodytext"
    @db.execute("select * from bodytext"){|doc_id, kw_id|
      print doc_id, ",", kw_id, "\n"
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
    num_of_docs = @db.get_first_value("select count(*) from docs")
#    p num_of_docs

    sql = <<SQL
select * 
from df LEFT OUTER JOIN 
(select kw_id, count(kw_id) from bodytext where doc_id = :doc_id group by kw_id) as bodytext
using (kw_id)
ORDER BY kw_id;
SQL
    docs.each{|doc_id, uri|
#      print doc_id, ","
      print uri, ","
      
      num_of_words = @db.get_first_value("select count(*) from bodytext where doc_id = :doc_id", :doc_id => doc_id)
      @db.execute(sql, :doc_id => doc_id){|kw_id, df, tf|
        tf = 0.0 if tf == nil
#        print "wk_id:", kw_id,"\n"
#        print "tf:", tf,"\n"
#        print "N:", num_of_words, "\n"
#        print "df:", df,"\n"
#        print "D:", num_of_docs, "\n"
        print (tf.to_f / num_of_words) * (1.0 + Math.log(num_of_docs.to_f / df)), ","
      }
      print "\n"
    }
  end

  
end

if $0 == __FILE__

  tfidf = TFIDF.new()

  uri = "http://url1"
  text = "今日もしないとね。今日もしないとね。昨日、昨日。"
  print text, "\n"
  tfidf.store(uri, text)
  
  uri = "http://url2"
  text = "今日もしないとね。明日。"
  print text, "\n"
  tfidf.store(uri, text)
  
  tfidf.showBodyText()
  tfidf.showDF()
#  tfidf.showTFIDF()

  tfidf.outputTFIDF()

#  tfidf.closeDB()

end
