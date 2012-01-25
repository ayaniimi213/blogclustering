#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetYahoo < AbstractGet

  def initialize(base)
    # base = http://blogs.yahoo.co.jp/madokayouchien
    super(base)
    end

  def extract
    @@years.each{|year|
      @@months.each{|month|
      # p date
      # p @base
      uri = @base + "/archive/" + year.to_s + "/" + month.to_s
      #p uri
      # open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/blogs\.yahoo\.co\.jp\/.+\/\d+\.html)(?:.*)/o).each{|url|
            p url
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
  get = GetYahoo.new(ARGV.shift)
  p get.extract
end
