#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'rubygems'
require 'sqlite3'
#  require 'MeCab' # need install MeCab and see mecab document

require 'easymecab'
require 'InitDB'

class TFIDF
  def initialize()
    #sqliteまわりの設定
    dbfile = "tfidf.sqlite"
    initdb = InitDB.new(dbfile)
    @db = SQLite3::Database.new(dbfile)
    @tfidf = Hash.new
  end
  
  def closeDB()
    @db.close
  end

  def store(uri, text)
    doc_id = 0
    doc_id = setDocId(uri)
    words = wakati(text)
    words.each{|word|
      # 原型を取りたい
      next if word["feature"] == "。"
      next if word["feature"] == "、"
      next if word["feature"] == "."
      next if word["feature"] == ","
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
      doc_id = @db.get_first_value('select count(*) from docs')
      doc_id = doc_id + 1
      sql = "insert into docs(uri) values(:uri)"
      @db.execute(sql, :uri => uri)
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
        sql = "select kw_id from keywords where word = :word"
        kw_id = @db.get_first_value(sql, :word => keyword)
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
#    print "storeTF\n"
    @db.transaction do
      sql = "select count from tf where kw_id = :kw_id"
      count = @db.get_first_value(sql, :kw_id => kw_id)
      if count == nil then
        count = 1
        sql = "insert into tf(count) values(:count)"
#        print "count new\n"
        @db.execute(sql, :count => count)
      else
        count = count + 1
        sql = "update tf set count = :count where kw_id = :kw_id"
#        print "countUPP!", count, "\n"
        @db.execute(sql, :kw_id => kw_id, :count => count)
      end
#      print kw_id, ",", count, "\n"
    end
  end
  
  def setTFIDF
    tfidf = 0.0
    sql = "select kw_id, score from tfidf"
    result = @db.query(sql)
    result.each{|id, score|
      @tfidf[id] = score
    }
  end

  def getTFIDF(kw_id)
#    tfidf = 0.0
#    sql = "select kw_id, score from tfidf"
#    result = @db.query(sql)
#    result.each{|id, score|
#      tfidf = score if id == kw_id
#    }
#    return tfidf
    return @tfidf[kw_id]
  end

  def showTFIDF
    @db.execute("select keywords.word, tfidf.score from keywords, tfidf where keywords.kw_id = tfidf.kw_id"){|keyword, score|
      print keyword, ",", score, "\n"
    }
  end

  def showDF
    @db.execute("select * from df"){|doc_id, count|
      print doc_id, ",", count, "\n"
    }
  end

  def showDocBody
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

    docs.each{|doc_id, uri|
      print uri, ","
      keywords =  @db.query("select kw_id from keywords order by kw_id")
      containedKeywords = @db.query("select DISTINCT kw_id from bodytext where doc_id = :doc_id", :doc_id => doc_id)

      keywords.each{|kw_id|
#        print kw_id, ","

        score = 0.0
        containedKeywords.each{|id|
          if kw_id == id then
            score = getTFIDF(kw_id)
          end
        }
        print score, ","
      }
      print "\n"
    }
  end

  
end

if $0 == __FILE__
  uri = "http://hoehoe/poepoe/"
  text = "今日もしないとね。今日もしないとね。"
  
  print text, "\n"
  tfidf = TFIDF.new()
  
  tfidf.store(uri, text)
  
  uri = "http://hoehoe/poepoe/"
  text = "今日もしないとね。"
  
  print text, "\n"
  
  tfidf.store(uri, text)
  
  #  tfidf.showDocBody()
  #  tfidf.showDF()
#  tfidf.showTFIDF()

  tfidf.outputTFIDF()

#  tfidf.closeDB()

end
