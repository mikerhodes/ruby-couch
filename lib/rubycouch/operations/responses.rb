#
# Helpers for responses.
#

require 'net/http'
require 'net/https'
require 'json'

##
# The return type for all response handlers
#
# This type will be returned from all `make_request` calls.
#
# `code`: status code as string
# `json`: on success, response body as json
# `raw`: if response isn't json, then the response body
# `success`: set if response is successful status code for request
#
class CouchResponse

  attr_reader :code
  attr_reader :raw
  attr_reader :success
  attr_reader :content_type

  def initialize(code, raw, success, content_type)
    @code = code
    @raw = raw
    @success = success
    @content_type = content_type
  end

  def json
    if content_type.downcase.eql? 'application/json'
      JSON.parse(raw)
    else
      raise "Non-JSON content type in response; cannot convert."
    end
  end

  def to_s
    "<CouchResponse code=\"#{@code}\", success=#{@success}," +
    " raw=\"#{@raw}\" content_type=\"#{@content_type}\">"
  end
end

def make_couch_response(response, body=nil)
  body = if body then body else response.body end
  success = (response.code.to_i >= 200 and response.code.to_i < 300)
  CouchResponse.new(response.code, body, success, response['Content-Type'])
end

##
# Provides a simple response handler that just wraps a ruby Net::HTTP
# response into something more CouchDB-friendly.
#
module SimpleResponseMixin

  def response_handler
    lambda { |response| make_couch_response response }
  end

end


##
# Provides a streaming response handler for use with views.
#
# Right now it _does_ make the assumption that each row is delivered
# on its own line in the output.
#
# N.b., not for changes?
module ViewStreamingResponseMixin

  ##
  # If set, Proc object will be called with row, idx pair.
  # This also prevents rows ending up in the `make_request` return value.
  attr_accessor :row_callback

  # This class takes advantage of the fact that a view returns a
  # result per line. And a row has a particular format, so it's
  # easy to find them with a simple `start_with?`.
  #
  # For reduced rows:
  # {"rows":[
  # {"key":null,"value":5}
  # ]}
  #
  # For non-reduced rows, this is:
  # {"total_rows":5,"offset":0,"rows":[
  # {"id":"kookaburra","key":"Dacelo novaeguineae","value":19},
  # {"id":"snipe","key":"Gallinago gallinago","value":19},
  # {"id":"llama","key":"Lama glama","value":10},
  # {"id":"badger","key":"Meles meles","value":11},
  # {"id":"aardvark","key":"Orycteropus afer","value":16}
  # ]}
  #
  # The class stores up the result rows in rows, and then just
  # parses the rest of the document excluding the rows.
  #
  # At some point, using json-stream or one of the yajl libs would
  # be better than this assumption.

  def response_handler

    if @row_callback

      # Save the current callback so it doesn't change
      # after we ask for the handler.
      inner_row_callback = @row_callback

      lambda { |response|

        # Return failure if needed
        return make_couch_response(response) unless response.kind_of?(Net::HTTPSuccess)

        non_row_body = ViewStreamingResponseMixin_stream_response(
          LineReader,
          response,
          inner_row_callback)
        make_couch_response(response, non_row_body)
      }

    else

      lambda { |response|
        make_couch_response(response)
      }

    end

  end

  ##
  # Processes a response body in a streaming manner using `line_reader_class`
  # to split the body into lines and calling back via `callback` per row.
  # Returns the remaining string content once row array contents have been
  # removed.
  def ViewStreamingResponseMixin_stream_response(line_reader_class, response, callback)
    non_row_body = ''
    row_idx = 0
    line_reader_class.read_body response do |line|
      line = line.strip
      if line.start_with? '{"key":' or line.start_with? '{"id":'
        # A result row; send to the callback
        callback.call JSON.parse(line.chomp(',')), row_idx
        row_idx += 1
      else
        # Not a row, it goes into the main return value
        non_row_body += line
      end
    end
    non_row_body
  end

end
