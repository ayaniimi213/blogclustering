#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetGoo < AbstractGet

  def initialize(base)
    # base = http://blog.goo.ne.jp/4410-y-y12139
    super(base)
    end

  def extract
    @@dates.each{|date|
      # p date
      # p @base
      uri = @base + "m/" + date.to_s
      p uri
      # open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/blog\.goo\.ne\.jp\/.+\/e\/\w+)(?:.*)/o).each{|url|
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
  get = GetGoo.new(ARGV.shift)
  p get.extract
end
