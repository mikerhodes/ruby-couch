#
# This file contains shared definition code and mixins.
#

require 'cgi'

require 'rubycouch/linereader'

##
# Handles standard query string funcitonality for request definitions.
#
# The mixin handles managing query items, k,v pairs in a hash, which are
# used to form the query string for a request.
#
# Definitions should add query string items using the merge_query_items
# method, which works the same as the hash::merge method -- if a key
# exists in the query items already, it's overwritten _not_ appended.
#
# The `query_string` method handles escaping, so values passed to
# `merge_query_items` should _not_ be escaped.
#
module QueryStringMixin

  def query_string
    ensure_query_items
    @QueryStringMixin_query_items.map { |k,v|
      "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
    }.join("&")
  end

  ##
  # Merge a hash of query items into the operation's.
  #
  # Can be used to add custom query string items to the operation.
  #
  def merge_query_items(items)
    ensure_query_items
    @QueryStringMixin_query_items.merge!(items)
  end

  def ensure_query_items
    @QueryStringMixin_query_items = {} if not @QueryStringMixin_query_items
  end

end

##
# Add `database_name=` and an implementation of `path` that munges the
# database name into the path.
#
# Instead of `path`, users of this class should provide `sub_path` containing
# the path to use after the database name. For example, getting a document
# might provide:
#
#     def sub_path
#       "/#{@doc_id}"
#     end
#
module DatabaseRequestMixin

  def database_name=(database_name)
    @database_name = database_name
  end

  def path
    if sub_path.start_with? '/'
      fixed_sub_path = sub_path[1..-1]
    else
      fixed_sub_path = sub_path
    end
    @path = "/#{@database_name}/#{fixed_sub_path}"
  end

end


##
# Module which provides the simple response behaviour of decoding
# JSON into a hash/array/primitive.
#
module SimpleJsonResponseMixin

  def response_handler
    lambda { |response| JSON.parse(response.read_body) }
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
        JSON.parse(non_row_body)
      }

    else

      lambda { |response|
        JSON.parse(response.read_body)
      }

    end

  end

end
