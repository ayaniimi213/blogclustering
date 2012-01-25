#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetWebry < AbstractGet

  def initialize(base)
    # base = http://clubkeiba-kettouhan.at.webry.info/
    super(base)
    end

  def extract
    @@dates.each{|date|
      # p date
      # p @base
      uri = @base + date.to_s + "/index.html"
      #  p uri
      #  open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/.*\.at\.webry\.info\/\d+\/article_\d+\.html)(?:.*)/o).each{|url|
            @urls.push(url.to_s)
          }
        }
      }
    }
    return @urls.uniq
  end
end

if $0 == __FILE__
  get = GetWebry.new(ARGV.shift)
  p get.extract
end
