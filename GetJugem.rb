#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require 'AbstractGet'

class GetJugem < AbstractGet

  def initialize(base)
    # base = http://jo4.jugem.jp/
    super(base)
    end

  def extract
    @@dates.each{|date|
      # p date
      # p @base
      uri = @base + "?month=" + date.to_s
      #  p uri
      #  open(uri,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
      open(uri) {|f|
        f.each_line {|line| 
          line.scan(/(?:.*)(http:\/\/.*\.jugem\.jp\/\?eid\=\d+)(?:.*)/o).each{|url|
            @urls.push(url.to_s)
          }
        }
      }
    }
    return @urls.uniq
  end
end

if $0 == __FILE__
  get = GetJugem.new(ARGV.shift)
  p get.extract
end
