#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

if ( RUBY_VERSION < "1.9" )
  require 'GetFactory'
else
  require_relative 'GetFactory'
end

#usage:
# ruby gets.rb http://clixup.blog52.fc2.com/
# ruby gets.rb http://ameblo.jp/umakichi-keiba/
# ruby gets.rb http://blog.livedoor.jp/keiba_m/
# ruby gets.rb http://taka0813.seesaa.net/
# ruby gets.rb http://plaza.rakuten.co.jp/runic/
# ruby gets.rb http://blogs.yahoo.co.jp/madokayouchien
# ruby gets.rb http://blog.goo.ne.jp/4410-y-y12139
# ruby gets.rb http://clubkeiba-kettouhan.at.webry.info/
# ruby gets.rb http://jo4.jugem.jp/
# ruby gets.rb http://d.hatena.ne.jp/eeechan/
# ruby gets.rb http://durandal1129.cocolog-nifty.com/blog/
# ruby gets.rb http://keiba777.dtiblog.com/

base = ARGV.shift
factory = GetFactory.new()
get = factory.create(base)
p get.extract
