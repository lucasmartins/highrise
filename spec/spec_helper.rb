require 'bundler'
require 'net/http'
require 'pry'
require 'pry-nav'
require 'digest/md5'
Bundler.setup

require File.join(File.dirname(__FILE__), '/../lib/highrise')

Highrise::Base.user        = ENV['HIGHRISE_USER']    || 'x'
Highrise::Base.oauth_token = ENV['HIGHRISE_TOKEN']   || 'TOKEN'
Highrise::Base.site        = ENV['HIGHRISE_SITE']    || 'https://www.example.com'

require 'highrise/pagination_behavior'
require 'highrise/searchable_behavior'
require 'highrise/taggable_behavior'

def http_testing?
  use_http = true
  ['HIGHRISE_SITE','HIGHRISE_TOKEN'].each do |env_var|
    if env_var==nil || env_var==''
      use_http=false
      break
    end
  end
  use_http
end

if http_testing?
  Highrise::Base.site        = ENV['HIGHRISE_SITE']
  Highrise::Base.oauth_token = ENV['HIGHRISE_TOKEN']
end

class ActiveResource::Connection
 # Creates new Net::HTTP instance for communication with
 # remote service and resources.
  def new_http
    if @proxy
      http = Net::HTTP.new(@site.host, @site.port, @proxy.host, @proxy.port, @proxy.user, @proxy.password)
    else
      http = Net::HTTP.new(@site.host, @site.port)
    end
    http.set_debug_output $stderr
    http
  end
  private
  def request(method, path, *arguments)
=begin    
    enc = Base64.encode64("#{ENV['HIGHRISE_TOKEN']}:")
    arguments[0]['Authorization']="Basic #{enc}"
=end
    puts '=========================='
    puts arguments.inspect
    puts path.inspect
    puts '=========================='
    result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
      payload[:method] = method
      payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"
      payload[:result] = http.send(method, path, *arguments)
    end
    handle_response(result)
  rescue Timeout::Error => e
    raise TimeoutError.new(e.message)
  rescue OpenSSL::SSL::SSLError => e
    raise SSLError.new(e.message)
  end
end