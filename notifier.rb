#!/usr/bin/ruby
require 'net/http'
require 'uri'
require 'json'
require 'openssl'

def api_get(uri_text, params, initheader = nil)
  uri = URI.parse(uri_text)
  uri.query = URI.encode_www_form(params)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  req = Net::HTTP::Get.new(uri, initheader = initheader)
  res = http.request(req)
  if res.header['location'] then
    return api_get(res.header['location'], {})
  end
  return res
end

def extract_title(uri_text)
  article = api_get( uri_text, {} )
  title = article.body[/title.*/].gsub(/title: /, '')
  puts title
end

res = JSON.parse( api_get( "https://api.github.com/repos/dit-rohm/mentor-blog/commits/#{ARGV[0]}", {} ).body )
res['files'].each do |file|
  if file['filename'].match(/.*\.[md|markdown]/)
    puts file['raw_url']
    extract_title( file['raw_url'] )
  end
end
