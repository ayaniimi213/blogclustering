#!/usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
$KCODE="u"

require 'open-uri'

class AbstractGet
  # @@dates = [201112, 201111, 201109, 201108, 201107, 201106, 201105, 201104, 201103, 201102, 201101]
  @@dates = [201111]
  @@years = [2011]
  # @@months = [12, 11, 10, 09, 08, 07, 06, 05, 04, 03, 02, 01]
  @@months = [11]

  def initialize(base)
    # base = blog url
    @urls = Array.new
    @base = base
    end

  def extract
  end

end
