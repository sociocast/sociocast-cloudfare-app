#!/usr/bin/env ruby -w

require 'openssl'
require 'optparse'
require 'net/http'
require 'uri'

# Returns the base-64 encoded HMAC SHA256 hash
def sign(message)
  hash = OpenSSL::HMAC.hexdigest('sha256', @secret, message)
  hash
end

def login(baseUrl)
  # Compute the signature
  timestamp = Time.now.to_i
  signature = sign(baseUrl + timestamp.to_s)
  
  # Create signed URI
  uri = URI(baseUrl)
  params = { 'cf-timestamp' => timestamp, 'cf-signature' => signature }
  uri.query = URI.encode_www_form(params)
  
  puts "Login URL: " + uri.to_s
  
  res = Net::HTTP.get_response(uri)
  
  puts "Response code: #{res.code}"
  puts "Response redirect locations: #{res.get_fields('Location')}"
  puts "Response cookies: #{res.get_fields('Set-Cookie')}"
  puts "Response body: #{res.body}"
  puts "SUCCESS!" if res.is_a?(Net::HTTPSuccess)
end

### The main test application ###

@server = 'localhost'
@port = '8080'
@accountId = 100938
@secret = ""

optparse = OptionParser.new do | opts |
  opts.banner = "Usage: #{File.basename($0)}"
  opts.on_tail("-h", "--help", "Display this screen") do
    puts opts
    exit 1
  end
  
  opts.on("-r", "--server url", "API server URL") do | i |
    @server = i
  end
  
  opts.on("-p", "--port port", "API server port") do | i |
    @port = i
  end
  
  opts.on("-a", "--account accountId", "CloudFlare account ID") do | i |
    @accountId = i
  end
  
  opts.on("-k", "--secret key", "CloudFlare App secret key") do | i |
    @secret = i
  end
end

begin 
  optparse.parse! ARGV
rescue OptionParser::InvalidOption => e
  puts e
  puts optparse
  exit 1
end

if (@secret == "")
  puts "You must specify the secret key with -k"
  exit 1
end

if ( @port == '80' )
  baseUrl = "http://#{@server}/cf/accounts/#{@accountId}/login"
else
  baseUrl = "http://#{@server}:#{@port}/cf/accounts/#{@accountId}/login"
end

login(baseUrl)
