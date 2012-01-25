#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetLivedoor < AbstractGet

  def initialize(base)
    # base = http://blog.livedoor.jp/keiba_m/
    super(base)
  end

  def extract
    @@years.each{|year|
      @@months.each{|month|
        uri = @base + "archives/" + year.to_s + "-" + month.to_s + ".html"
        #  p uri
        #  open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
        open(uri) {|f|
          f.each_line {|line| 
            line.scan(/(?:.*)<a name="(\d+)">(?:.*)/o).each{|date|
#              if date != ""
                url = uri + "#" + date.to_s
                @urls.push(url)
#              end
            }
          }
        }
      }
    }
    return @urls.uniq
  end
end

if $0 == __FILE__
  get = GetLivedoor.new(ARGV.shift)
  p get.extract
end
