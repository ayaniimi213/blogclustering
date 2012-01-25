#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetRakuten < AbstractGet

  def initialize(base)
    # base = http://plaza.rakuten.co.jp/runic/
    super(base)
    end

  def extract
    @@dates.each{|date|
      # p date
      # p @base
      uri = @base + "backnumber/" + date.to_s
      #p uri
      # open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/plaza\.rakuten\.co\.jp\/.+\/diary\/\d+\/)(?:.*)/o).each{|url|
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
  get = GetRakuten.new(ARGV.shift)
  p get.extract
end
