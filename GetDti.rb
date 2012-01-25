#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetDti < AbstractGet

  def initialize(base)
    # base = http://keiba777.dtiblog.com/
    super(base)
    end

  def extract
    @@dates.each{|date|
      # p date
      # p @base
      uri = @base + "blog-date-" + date.to_s + ".html"
      p uri
      # open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(blog-entry-\d+\.html)(?:.*)/o).each{|url|
           url_add = @base + url.to_s
            @urls.push(url_add.to_s)
          }
        }
      }
    }
    return @urls.uniq
  end
end

if $0 == __FILE__
  get = GetDti.new(ARGV.shift)
  p get.extract
end
