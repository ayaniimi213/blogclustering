#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetNifty < AbstractGet

  def initialize(base)
    # base = http://durandal1129.cocolog-nifty.com/blog/
    super(base)
    end

  def extract
    @@years.each{|year|
      @@months.each{|month|
      uri = @base + year.to_s + "/" + month.to_s + "/index.html"
      #  p uri
      #  open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/.*\.cocolog-nifty\.com\/blog\/\d+\/\d+\/post-\w+\.html)(?:.*)/o).each{|url|
            @urls.push(url.to_s)
            }
          }
        }
      }
    }
    return @urls.uniq
  end
end

if $0 == __FILE__
  get = GetNifty.new(ARGV.shift)
  p get.extract
end

