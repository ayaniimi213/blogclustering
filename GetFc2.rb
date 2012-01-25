#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetFc2 < AbstractGet

  def initialize(base)
    # base = http://clixup.blog52.fc2.com/
    super(base)
  end

  def extract
    @@dates.each{|date|
      # p date
      # p @base
      uri = @base + "blog-date-" + date.to_s + ".html"
      #  p uri
      #  open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/.*\.fc2\.com\/blog-entry-\d+\.html)(?:.*)/o).each{|url|
            @urls.push(url.to_s)
          }
        }
      }
    }
    return @urls.uniq
  end
end

if $0 == __FILE__
  get = GetFc2.new(ARGV.shift)
  p get.extract
end
