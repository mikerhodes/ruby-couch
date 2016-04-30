#
# This file contains shared definition code and mixins.
#

require 'cgi'

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
    lambda { |response| JSON.parse(response.body) }
  end

end
