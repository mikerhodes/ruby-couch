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
  attr_accessor :response_handler
  attr_accessor :basic_auth

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
    @response_handler = nil
    @basic_auth = nil
  end

end

class Requestor

  def processed_response_for(template)
    raise "processed_response_for() requires `template` not be nil" unless template
    raise "processed_response_for() requires `template.response_handler` not be nil" unless template.response_handler
    # template.response_handler.call(response_for(template))
    response_for(template)
  end

  def response_for(template)
    client = Net::HTTP.start(
              template.host, template.port,
              :use_ssl => template.scheme == 'https',
              :verify_mode => OpenSSL::SSL::VERIFY_PEER)

    request = request_for(template)
    result = nil
    # Called with a block to allow response handler to stream response body
    client.request(request) do |response|
      result = template.response_handler.call(response)
    end
    client.finish()
    result
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
    request.basic_auth(
      template.basic_auth[:username],
      template.basic_auth[:password]
    ) if template.basic_auth

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
