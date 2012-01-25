#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetAmeblo < AbstractGet

  def initialize(base)
    # base = http://ameblo.jp/umakichi-keiba/
    super(base)
    end

  def extract
    @@dates.each{|date|
      # p date
      # p @base
      uri = @base + "archive1-" + date.to_s + ".html"
#      p uri
      # open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/ameblo\.jp\/.+\/day-\d+\.html)(?:.*)/o).each{|url|
            p url
            @urls.push(url.to_s)
          }
        }
      }
    }
    return @urls.uniq
  end
end

if $0 == __FILE__
  get = GetAmeblo.new(ARGV.shift)
  p get.extract
end
