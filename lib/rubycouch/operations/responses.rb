#
# Helpers for responses.
#

##
# The return type for all response handlers
#
# This type will be returned from all `make_request` calls.
#
Struct.new("CouchResponse", :code, :json)


##
# Module which provides the simple response behaviour of decoding
# JSON into a hash/array/primitive.
#
module SimpleJsonResponseMixin

  def response_handler
    lambda { |response|
      Struct::CouchResponse.new(response.code, JSON.parse(response.read_body))
    }
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

    if not @row_callback.nil?

      lambda { |response|
        non_row_body = ''
        row_idx = 0
        LineReader.read_body response do |line|
          line = line.strip
          if line.start_with? '{"key":' or line.start_with? '{"id":'
            # A result row; send to the row_callback
            row_callback.call JSON.parse(line.chomp(',')), row_idx
            row_idx += 1
          else
            # Not a row, it goes into the main return value
            non_row_body += line
          end
        end
        Struct::CouchResponse.new(response.code, JSON.parse(non_row_body))
      }

    else

      lambda { |response|
        Struct::CouchResponse.new(response.code, JSON.parse(response.read_body))
      }

    end

  end

end
