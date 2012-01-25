#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"
# 
# easymecab.rb
# from http://d.hatena.ne.jp/kenkitii/20060705/p1
#
require "tempfile"

class MeCab
	def initialize(option)
#		@path = 'c:\Program Files\MeCab\bin\mecab.exe' # MeCabへのパス
		@path = '/usr/local/bin/mecab' # MeCabへのパス
		@option = option
	end
	def parse_file(s)
		cmd_string = [@path, @option, s].join(" ")
		word_list = []
		io = IO.popen(cmd_string, "r")
		until io.eof?
			out = []
			# 表層形\t品詞,品詞細分類1,品詞細分類2,品詞細分類3,活用形,活用型,原形,読み,発音
			out = io.gets.chomp.split("\t")
			surface = out[0]
			tags = out[1].split(",") unless surface == "EOS"
			next if tags == nil
			yomi = tags[7]
			feature = tags[6]
			wordclass = (tags[0..3]).join(",") # 品詞,品詞細分類1,品詞細分類2,品詞細分類3
			wordclass = "EOS" if surface == "EOS"
			word_list << {"surface"=>surface, "yomi"=>yomi, "feature"=>feature, "wordclass"=>wordclass}
		end
		return word_list
	end
	def parse(s)
		file = Tempfile.new("mecab")
		file.puts(s)
		file.close
		return parse_file(file.path)
	end

	def wakati(s)
		file = Tempfile.new("mecab")
		file.puts(s)
		file.close
		return strip_by_wordclass(parse_file(file.path))
	end

	def strip_by_wordclass(n)
		n.find_all{|word|
			wordclass = word["wordclass"].split(",")
			wordclass[0] == "名詞" and wordclass[1] != "数" and wordclass[1] != "代名詞"
		}.collect{|word| word["surface"]}.join(" ")
	end
end

if $0 == __FILE__
	# parse words by MeCab
	m = MeCab.new("")
	n = m.parse('日本語を解析する')
	keywords = m.strip_by_wordclass(n)
	p keywords
end
