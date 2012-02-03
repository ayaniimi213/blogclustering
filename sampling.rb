#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'rubygems'
require 'sqlite3'

class Sampling
  def initialize(dbfile)
    @db = SQLite3::Database.new(dbfile)
    @db.cache_size = 80000 # PRAGMA page_countを見て、とりあえずそれより大きい値を設定
  end

  def sampling(size, times)
#    docs = Array.new
    docs = @db.execute("select DISTINCT doc_id from bodytext").flatten

    docs.each_index{|i|
      j = rand(i)
      docs[j], docs[i] = docs[i], docs[j]
    }
    
    i = 0
    times.times {
      i = i + 1
      sampleset = Array.new
      size.times {
        sampleset.push(docs.shift)
      }
      createtable_bodytext(i)
      insertvalue_bodytext(sampleset, i)
      createtable_docs(i)
      insertvalue_docs(sampleset, i)
    }

    
  end

  def createtable_bodytext(num)
    sql = <<SQL
create table tablename (
  doc_id integer,
  kw_id integer
);
SQL
    print(sql.sub("tablename", "bodytext_" + num.to_s))
    @db.execute(sql.sub("tablename", "bodytext_" + num.to_s))
    @db.execute("create index tablename_doc_id_idx on tablename (doc_id)".gsub("tablename", "bodytext_" + num.to_s))
    @db.execute("create index tablename_kw_id_idx on tablename (kw_id)".gsub("tablename", "bodytext_" + num.to_s))
    end

  def createtable_docs(num)
    sql = <<SQL
create table tablename (
 doc_id INTEGER PRIMARY KEY,
 uri text
);
SQL
    
    db.execute(sql.sub("tablename", "docs_" + num.to_s))
    db.execute("create index tablename_idx on tablename (doc_id)".gsub("tablename", "docs_" + num.to_s))
    end

  def insertvalue_bodytext(docs, num)
    sql = <<SQL
insert into tablename (doc_id, kw_id)
select doc_id, kw_id from bodytext
where doc_id in (:docs);
SQL
    @db.execute(sql.sub("tablename", "bodytext_" + num.to_s), :docs => docs.join("."))
  end

  def insertvalue_docs(docs, num)
    sql = <<SQL
insert into tablename (doc_id, uri)
select doc_id, uri from docs
where doc_id in (:docs);
SQL
    @db.execute(sql.sub("tablename", "docs_" + num.to_s), :docs => docs.join("."))
  end


end

if $0 == __FILE__
  sampling = Sampling.new("tfidf.sqlite")
  sampling.sampling(100,10)
end
