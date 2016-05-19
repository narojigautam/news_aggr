#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'zip'
require 'stringio'
require 'active_support/core_ext/hash/conversions'
require 'pry'

Dir[File.join(File.expand_path(File.dirname(__FILE__)), "../lib/*.rb")].map { |file| require file }
puts "Enter the news feed url"
news_feed_url = gets
news_feed_url.lstrip!
news_feed_url.rstrip!

news_feed_service = NewsFeedService.new(news_feed_url)

news_feed_service.update_news_articles

puts "News Articles updated in store!"
