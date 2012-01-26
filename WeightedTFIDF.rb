#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'TFIDF'
require 'WeightedInitDB'

class WeightedTFIDF < TFIDF

  def initialize(dbfile)
    #sqliteまわりの設定
    initdb = WeightedInitDB.new(dbfile) unless FileTest.file?(dbfile)
    @db = SQLite3::Database.new(dbfile)
    @db.cache_size = 80000 # PRAGMA page_countを見て、とりあえずそれより大きい値を設定
  end

  def loadDic(filename, weight)
    setDF_table(@db)

    # 辞書の内容を読み込む

#    @weight =  2.0 # 重み一定
    @weight =  weight

    setImportant_table(@db)
    file = open(filename)
    while word = file.gets do
      word.chomp!
      kw_id = setKeywordId(word)
#      print kw_id, word, "\n"
      storeImportant(kw_id, @weight)
    end
    file.close

  end

  def setImportant_table(db)
    db.execute("delete from important")
    sql = <<SQL
insert into important(kw_id, weight)
select kw_id, 1.0 from df
SQL
    db.execute(sql)
  end

  def storeImportant(kw_id, weight)
    sql = "replace into important(kw_id, weight) values(:kw_id, :weight)"
    @db.execute(sql, :kw_id => kw_id, :weight => weight)
#    print kw_id, ",", weight, "\n"
  end

  def showWTFIDF
    print "show WTFIDF\n"
    @db.execute("select keywords.word, total(wtfidf.score) from keywords, wtfidf where keywords.kw_id = wtfidf.kw_id group by kw_id order by tfidf.score"){|keyword, score|
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
    setDF_table(@db)

#    words = @db.query("select word from keywords order by kw_id")
    words = @db.query("select keywords.word from keywords,df where keywords.kw_id = df.kw_id order by keywords.kw_id")
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
from 
(select * 
from df LEFT OUTER JOIN 
(select kw_id, count(kw_id) from bodytext where doc_id = :doc_id group by kw_id) as bodytext
using (kw_id)
)
INNER JOIN important
using (kw_id)
ORDER BY kw_id;
SQL
    docs.each{|doc_id, uri|
#      print doc_id, ","
      print uri, ","
      
      num_of_words = @db.get_first_value("select count(*) from bodytext where doc_id = :doc_id", :doc_id => doc_id)
      @db.execute(sql, :doc_id => doc_id){|kw_id, df, tf, weight|
        tf = 0.0 if tf == nil
#        print "wk_id:", kw_id,"\n"
#        print "tf:", tf,"\n"
#        print "N:", num_of_words, "\n"
#        print "df:", df,"\n"
#        print "D:", num_of_docs, "\n"
        print weight * (tf.to_f / num_of_words) * (1.0 + Math.log(num_of_docs.to_f / df)), ","
      }
      print "\n"
    }
  end

end

if $0 == __FILE__

  tfidf = WeightedTFIDF.new("tfidf.sqlite")

  uri = "http://url1"
  text = "今日もしないとね。今日もしないとね。昨日、昨日。"
  print text, "\n"
  tfidf.store(uri, text)
  
  uri = "http://url2"
  text = "今日もしないとね。明日。"
  print text, "\n"
  tfidf.store(uri, text)
  
  tfidf.showBodyText()
#  tfidf.showDF()

#  tfidf.showTFIDF()
#  tfidf.showWTFIDF()

    tfidf.loadDic("test.dic", 2.0)
#    tfidf.showImportant()
  tfidf.outputTFIDF()

#  tfidf.closeDB()

end
