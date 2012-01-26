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
#    db.execute("drop table important")
    sql = <<SQL
create table important (
 kw_id INTEGER PRIMARY KEY,
 weight real
);
SQL
    
    db.execute(sql)

    sql = <<SQL
insert into important(kw_id, weight)
select kw_id, 1.0 from df
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
  
end
