require 'net/http'
require 'net/https'
require 'uri'
require 'json'

class RequestTemplate

  attr_accessor :method
  attr_accessor :scheme
  attr_accessor :port
  attr_accessor :host
  attr_accessor :path
  attr_accessor :query
  attr_accessor :body
  attr_accessor :content_type
  attr_accessor :accept

  def initialize(uri)
    @method = 'GET'
    @scheme = uri.scheme
    @host = uri.host
    @port = uri.port
    @path = uri.path
    @query = uri.query
    @body = nil
    @content_type = 'application/json'
    @accept = 'application/json'
  end

end

class Requestor

  def response_json_for(template)
    JSON.parse(response_for(template).body)
  end

  def response_for(template)
    Net::HTTP.start(
              template.host, template.port,
              :use_ssl => template.scheme == 'https',
              :verify_mode => OpenSSL::SSL::VERIFY_PEER) do |client|
      request = request_for(template)
      client.request(request)
    end
  end

  def request_for(template)
    raise "request_for() requires `template` not be nil" unless template

    uri = uri_for(template)
    request = case template.method
    when 'GET'
      Net::HTTP::Get.new(uri)
    when 'POST'
      Net::HTTP::Post.new(uri)
    when 'PUT'
      Net::HTTP::Put.new(uri)
    when 'DELETE'
      Net::HTTP::Delete.new(uri)
    when 'COPY'
      Net::HTTP::Copy.new(uri)
    else
      raise "Unsupported HTTP method: #{template.method}"
    end

    request.body = template.body if template.body
    request.content_type = template.content_type

    request['Accept'] = template.accept

    request
  end

  def uri_for(template)
    args = {
      :host => template.host,
      :port => template.port,
      :path => template.path,
      :query => template.query
    }

    if template.scheme == 'https' then
      URI::HTTPS.build(args)
    else
      URI::HTTP.build(args)
    end
  end

end
