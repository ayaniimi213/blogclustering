#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'rubygems'
require 'sqlite3'

class WeightedInitDB < InitDB
  def initialize(dbfile)
    createTable(dbfile)
  end
  
  def createTable(dbfile)
    super(dbfile)
    db = SQLite3::Database.new(dbfile)
    createImportant_table(db)
    createWTFIDF_table(db)
    db.close
  end

    
    
  def createImportant_table(db)
    sql = <<SQL
create table important (
 kw_id INTEGER PRIMARY KEY,
 weight real
);
SQL
    
    db.execute(sql)
    db.execute("create index important_idx on important(kw_id)")
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
    db.execute("create index wtfidf_doc_id_idx on wtfidf(doc_id)")
    db.execute("create index wtfidf_kw_id_idx on wtfidf(kw_id)")

  end
  
end
