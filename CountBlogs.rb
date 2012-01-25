#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'
require "nkf"

class CountBlogs

  def initialize(url)
    # base = http://clixup.blog52.fc2.com/
    @url = url
#    p @url
  end
  
  def isWP
    #  open(@url,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
    open(@url) {|f|
      f.each_line {|line| 
        if ( RUBY_VERSION < "1.9" )
          line = NKF::nkf('-wm0',line)
        else
          line = line.encode("UTF-8")
        end
        line.scan(/wordpress/io).each{|blog|
          return true
        }
      }
    }
    return false
  end

  def isMT
    #  open(@url,{:proxy => "http://proxy.fun.ac.jp:8080/"}) {|f|
    open(@url) {|f|
      f.each_line {|line| 
        if ( RUBY_VERSION < "1.9" )
          line = NKF::nkf('-wm0',line)
        else
          line = line.encode("UTF-8")
        end
        line.scan(/Powered by Movable Type/io).each{|blog|
          return true
        }
      }
    }
    return false
  end

  def get_servername
    servername = ""
    site = @url.split(/\//)[2]
    #    put "#{url}"
    servername = "fc2.com" if site =~ /.*\.fc2\.com/o
    servername = "dtiblog.com" if site =~ /.*\.dtiblog\.com/o
    servername = "exblog.jp" if site =~ /.*\.exblog\.jp/o
    servername = "livedoor.biz" if site =~ /.*\.livedoor\.biz/o
    servername = "at.webry.info" if site =~ /.*\.at.webry\.info/o
    servername = "seesaa.net" if site =~ /.*\.seesaa\.net/o
    servername = "jugem.jp" if site =~ /.*\.jugem\.jp/o
    servername = "blog.ocn.ne.jp" if site =~ /.*\.blog\.ocn\.ne\.jp/o
    servername = "cocolog-nifty.com" if site =~ /.*\.cocolog-nifty\.com/o
    servername = "blogspot.com" if site =~ /.*\.blogspot\.com/o
    servername = "sakura.ne.jp" if site =~ /.*\.sakura\.ne\.jp/o
    servername = "blog.so-net.ne.jp" if site =~ /.*\.blog\.so-net\.ne\.jp/o
    servername = "ap.teacup.com" if site =~ /.*\.ap\.teacup\.com/o

    if servername == "" and isWP == true
      servername = "WordPress"
    elsif servername == "" and isMT == true
      servername = "Movable Type"
    else
      servername = site
    end
    return servername
  end
end

if $0 == __FILE__
  blogs = Hash.new(0)
  wpsites = Array.new
  mtsites = Array.new
  
  open(ARGV.shift){|f|
    count = 0
    f.each_line{|line|
      line.chomp!
      next unless line =~ /^http:/o
      print "."

      blog = CountBlogs.new(line)
      servername = blog.get_servername
      blogs[servername] = blogs[servername] + 1 if servername != ""
      wpsites << line if servername == "WordPress"
      mtsites << line if servername == "Movable Type"
    }
  }
  
  blogs.to_a.sort{|a,b|
    b[1] <=> a[1]}.each{|blog|
    puts "#{blog[0]}:#{blog[1]}"
  }
  puts "WordPress:"
  wpsites.each{|site|
    puts "#{site}"
  }
  puts "Movable Type:"
  mtsites.each{|site|
    puts "#{site}"
  }
end
