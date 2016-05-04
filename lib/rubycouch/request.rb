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
  attr_accessor :body_stream
  attr_accessor :content_type
  attr_accessor :accept
  attr_accessor :response_handler
  attr_accessor :basic_auth
  attr_accessor :header_items

  def initialize(uri)
    @method = 'GET'
    @scheme = uri.scheme
    @host = uri.host
    @port = uri.port
    @path = uri.path
    @query = uri.query
    @body = nil
    @body_stream = nil
    @content_type = 'application/json'
    @accept = 'application/json'
    @response_handler = nil
    @basic_auth = nil
    @header_items = nil
  end

end

class Requestor

  ##
  # Execute the request, passing a possible callback onto the response
  # handler.
  #
  # If used, the callback is expected to be a Proc object, such as one created
  # by &block.
  def response_for(template, callback)
    raise "processed_response_for() requires `template` not be nil" unless template
    raise "processed_response_for() requires `template.response_handler` not be nil" unless template.response_handler

    client = Net::HTTP.start(
              template.host, template.port,
              :use_ssl => template.scheme == 'https',
              :verify_mode => OpenSSL::SSL::VERIFY_PEER)

    request = request_for(template)
    result = nil
    # Called with a block to allow response handler to stream response body
    client.request(request) do |response|
      result = template.response_handler.call(response, callback)
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

    # For headers, first set those we have attrs for, then allow
    # for overriding with the explicit header_items field.
    request['Accept'] = template.accept
    request.content_type = template.content_type
    request.basic_auth(
      template.basic_auth[:username],
      template.basic_auth[:password]
    ) if template.basic_auth

    if template.header_items
      template.header_items.each do |k,v|
        request[k] = v
      end
    end

    # Rely on Net::HTTP's behaviour if we end up assigning both
    request.body = template.body if template.body
    request.body_stream = template.body_stream if template.body_stream

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
