#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"
require "nkf"

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'set'
require 'uri'
if ( RUBY_VERSION < "1.9" )
  require 'extractcontent'
  require 'mwextractcontenttest'
else
  require_relative 'extractcontent'
  require_relative 'mwextractcontenttest'
end

class MyMwExtractCountentTest < MwExtractCountentTest

  # 初期化
  def initialize(sameSite)
    super(sameSite)
    @body_text
  end

  # 取得したページの解析、加工、保存
  def analyzePage(url, urlMap)
    p url
    begin
      urlMap[url] = 1
      doc = Hpricot(open(url))
      uri = URI.parse(url)

      # 本文抽出
      body, title = ExtractContent::analyse(doc.to_html)

      # 本文保存
#      saveResult(url, title, body, doc)
#      print title, "\n"
      text = ""
      if ( RUBY_VERSION < "1.9" )
        text = NKF::nkf('-wm0',body)
      else
        text = body.encode("UTF-8")
      end

#      print text
      @body_text = text

      sleep 5

      # リンクを取得する
      (doc/"a").each do |elem|
        href = elem["href"]
        # スラッシュで始まる場合は、hostを追加する
        if href =~ /^\//
          href = "http://#{uri.host}#{href}"
        # URLが取得ページと同一ホストの場合は、そのまま取得
        elsif Regexp.new("#{uri.host}").match(href)
        # http://で始まり、
        elsif @sameSite == 1 and href =~ /^http:\/\//
          next
        # その他の場合は、取得URLのパスの後にURLを付加する
        elsif not href =~ /^http:\/\//
          href = "http://#{uri.host}#{uri.path}#{href}"
        end
        urlMap[href] = 0
      end
   end
  rescue => esc
    p esc
  end

  def getBody
    return @body_text
  end
end
