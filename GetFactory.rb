#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'

if ( RUBY_VERSION < "1.9" )
  require 'AbstractGet'
  require 'GetAmeblo'
  require 'GetFc2'
  require 'GetLivedoor'
  require 'GetSeesaa'
  require 'GetRakuten'
  require 'GetYahoo'
  require 'GetGoo'
  require 'GetWebry'
  require 'GetJugem'
  require 'GetHatena'
  require 'GetNifty'
  require 'GetDti'
else
  require_relative 'AbstractGet'
  require_relative 'GetAmeblo'
  require_relative 'GetFc2'
  require_relative 'GetLivedoor'
  require_relative 'GetSeesaa'
  require_relative 'GetRakuten'
  require_relative 'GetYahoo'
  require_relative 'GetGoo'
  require_relative 'GetWebry'
  require_relative 'GetJugem'
  require_relative 'GetHatena'
  require_relative 'GetNifty'
  require_relative 'GetDti'
end

class GetFactory
  def initialize()
  end

  def create(base)
   if base =~ /http:\/\/.*\.fc2\.com/
      # base = http://clixup.blog52.fc2.com/
      #  print "fc2.com\n"
      get = GetFc2.new(base)
    elsif base =~ /http:\/\/ameblo\.jp\/.*/
      # http://ameblo.jp/umakichi-keiba/
      #  print "ameblo.jp\n"
      get = GetAmeblo.new(base)
    elsif base =~ /http:\/\/blog\.livedoor\.jp\/.*/
      # base = http://blog.livedoor.jp/keiba_m/
      #  print "blog.livedoor.jp\n"
      get = GetLivedoor.new(base)
    elsif base =~ /http:\/\/.*\.seesaa\.net/
      # base = http://taka0813.seesaa.net/
      #  print "seesaa.net\n"
      get = GetSeesaa.new(base)
    elsif base =~ /http:\/\/plaza\.rakuten\.co\.jp\/.*/
      # base = http://plaza.rakuten.co.jp/runic/
      #  print "rakuten.co.jp\n"
      get = GetRakuten.new(base)
    elsif base =~ /http:\/\/blogs\.yahoo\.co\.jp\/.*/
      # base = http://blogs.yahoo.co.jp/madokayouchien
      #  print "yahoo.co.jp\n"
      get = GetYahoo.new(base)
    elsif base =~ /http:\/\/blog\.goo\.ne\.jp\/.*/
      # base = http://blog.goo.ne.jp/4410-y-y12139
      #  print "goo.ne.jp\n"
      get = GetGoo.new(base)
    elsif base =~ /http:\/\/.*\.at\.webry\.info/
      # base = http://clubkeiba-kettouhan.at.webry.info/
      #  print "webry.info\n"
      get = GetWebry.new(base)
    elsif base =~ /http:\/\/.*\.jugem\.jp/
      # base = http://jo4.jugem.jp/
      #  print "jugem.jp\n"
      get = GetJugem.new(base)
    elsif base =~ /http:\/\/d.hatena\.ne\.jp\/.*/
      # base = http://d.hatena.ne.jp/eeechan/
      #  print "Hatena.jp\n"
      get = GetHatena.new(base)
    elsif base =~ /http:\/\/.*\.cocolog-nifty\.com\/blog/
      # base = http://durandal1129.cocolog-nifty.com/blog/
      #  print "nifty.com\n"
      get = GetNifty.new(base)
    elsif base =~ /http:\/\/.*\.dtiblog\.com/
      # base = http://keiba777.dtiblog.com/
      #  print "dtiblog.com\n"
      get = GetDti.new(base)
    end
    
    return get
  end
end
