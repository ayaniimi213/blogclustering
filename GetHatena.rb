#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetHatena < AbstractGet

  def initialize(base)
    # base = http://d.hatena.ne.jp/eeechan/
    super(base)
    end

  def extract
    @@dates.each{|date|
      # p date
      # p @base
      uri = @base + "archive/" + date.to_s
      #p uri
      # open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/d.hatena\.ne\.jp\/.*\d+\/\d+)(?:.*)/o).each{|url|
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
  get = GetHatena.new(ARGV.shift)
  p get.extract
end
