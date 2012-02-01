#!/usr/bin/ruby -Ku
$KCODE="u"

# Author:: Masato Watanabe
# License:: BSD
#
# 引数で指定されたURLをExtractContentで解析し、解析結果のTITLEとBODYを、
# 取得したHTMLのBODY直下に付加する形でファイル出力します。
#
# ExtractContentとHpricotを使用しています。
# hpricot未インストールの人は、「gem install hpricot」を実行してください
# ExtractContentはググって取ってきてください。
#
# 物は試し、環境が揃ったら当ファイルと「extractcontent.rb」を同一階層に配置して、
# ruby mwextractcontenttest.rb http://blog.mwsoft.jp/article/29068314.html
# を実行してみてください。同一階層に「http___blog.mwsoft.jp_article_29068314.html」
# というファイルが出来ていれば成功です。
# ファイル名はURLをWindowsで使えない文字をアンスコに変換したものになります。
#
# 速度が遅いのは、リクエストするたびに遠慮がちに5秒スリープしているせいです。
#
# ☆引数
# 1, startUrl : 取得開始URL。
# 2, depth    : 取得深度。指定回数だけ、URL内のリンクをたどってリクエストを発行します。
#               省略可。デフォルト値 = 1（指定URLのみ取得）。
# 3, sameSite : 1: 再起取得時に同一サイトのみ取得,  1以外: 他サイトも取得
#
# ☆実行例
# 1, 指定URLのみ取得                   : ruby mwextractcontenttest.rb http://blog.mwsoft.jp/
# 2, 指定URLとそのページのリンクを取得 : ruby mwextractcontenttest.rb http://blog.mwsoft.jp/ 2
# 3, 他サイトのページも取得            : ruby mwextractcontenttest.rb http://blog.mwsoft.jp/ 2 0

require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'set'
require 'uri'
require 'extractcontent'

class MwExtractCountentTest

  # 初期化
  def initialize(sameSite)
    # 同一サイトのみ取得する（1:同一サイトのみ, その他:同一サイト以外も取得）
    @sameSite = sameSite
    # オプション値の指定
    ExtractContent::set_default({:waste_expressions => /お問い合わせ|会社概要/})
  end

  # テスト実行
  def test(startUrl, depth)
    urlMap = {startUrl => 0}
    depth.times do |num|
      getWebPage(urlMap)
    end
  end

  # URLの中で既得以外のものを全て取得する
  def getWebPage(urlMap)
    # ベースになるサイトを取得
    urlArgs = []
    urlMap.each do |url, flag|
      next if flag == 1
      urlArgs.push(url)
    end
    
    urlArgs.each do |url|
      analyzePage(url, urlMap)
    end
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
      saveResult(url, title, body, doc)
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

  # ファイル保存
  def saveResult(url, title, body, doc)
    # ファイル名
    fileName = url
    [ '"', '*', '/', ':', '<', '>', '?', '\\', '|' ].each do |escChar|
      fileName = fileName.gsub(escChar, "_")
    end
    if not fileName =~ /\.html$/
      fileName += ".html"
    end

    bodyElem = (doc/"body").first
    bodyElem.inner_html("<div style='border:solid 3px'><b>#{title}</b><br><br>#{body}</div>#{bodyElem.inner_html}")

    file = File.open(fileName, "w")
    file.puts doc.to_html
    file.close
  end
end

# 引数情報
if ARGV.size < 1
  p "@param startUrl"
  p "@param depth = 1"
  p "@param sameSite = 1"
  exit
end

# 探索元URL
startUrl  = ARGV[0]
# 深さ
depth    = ARGV.size > 1 ? ARGV[1] : "1"
# 同一サイトのみ探索
sameSite = ARGV.size > 2 ? ARGV[2] : "1"

# テストクラス実行
mwTest = MwExtractCountentTest.new(sameSite.to_i)
mwTest.test(startUrl, depth.to_i)

