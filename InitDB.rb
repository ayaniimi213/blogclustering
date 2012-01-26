#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'rubygems'
require 'sqlite3'

class InitDB

  def initialize(dbfile)
    createTable(dbfile)
  end

  def createTable(dbfile)
    db = SQLite3::Database.new(dbfile)
    createKeywords_table(db)
    createDocs_table(db)
    createTF_table(db)
    createBodtText_table(db)
    createDF_view(db)
    createTFIDF_table(db)
    db.close
  end

  def createKeywords_table(db)
    sql = <<SQL
create table keywords (
 kw_id INTEGER PRIMARY KEY,
 word text
);
SQL
    
    db.execute(sql)
  end
    
  def createDocs_table(db)
    sql = <<SQL
create table docs (
 doc_id INTEGER PRIMARY KEY,
 uri text
);
SQL
    
    db.execute(sql)
end
  
  def createTF_table(db)
    sql = <<SQL
create table tf (
 kw_id INTEGER PRIMARY KEY,
 count integer
);
SQL
    
    db.execute(sql)
  end

  def createBodtText_table(db)
    sql = <<SQL
create table bodytext (
  doc_id integer,
  kw_id integer
);
SQL
    
    db.execute(sql)
    end

  def createDF_view(db)
    sql = <<SQL
create view df as select kw_id, count(*) as count from
(select DISTINCT * from bodytext)
 group by kw_id;
SQL
    
    db.execute(sql)
    end

  def createTFIDF_table(db)
    sql = <<SQL
create table tfidf (
 doc_id integer,
 kw_id integer,
 score real
);
SQL
    
    db.execute(sql)
  end
  
end
 
