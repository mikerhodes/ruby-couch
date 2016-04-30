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
# Marker for requests to the main instance endpoint, like _all_dbs
#
class InstanceRequestDefinition

end

class InstanceInfo < InstanceRequestDefinition

  def method
    'GET'
  end

  def path
    '/'
  end

end

class AllDbs < InstanceRequestDefinition

  def method
    'GET'
  end

  def path
    '/_all_dbs'
  end

end

##
# Marker for requests to the a database endpoint, like getting a document
#
# Sub-classes contain real requests, and are expected to provide at
# least a custom `sub_path` method which returns the un-escaped value
# to use as the path after the database name path portion. So for a
# document GET:
#
#     def sub_path
#       "/#{@doc_id}"
#     end
#
# I guess this should probably be a mixin of somekind...
#
class DatabaseRequestDefinition

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

class DatabaseInfo < DatabaseRequestDefinition

  def method
    'GET'
  end

  def sub_path
    '/'
  end

end

class GetDocument < DatabaseRequestDefinition

  include QueryStringMixin

  def initialize(doc_id)
    @doc_id = doc_id
  end

  def method
    'GET'
  end

  def rev_id=(rev_id)
    merge_query_items({:rev => rev_id})
  end

  def sub_path
    "/#{@doc_id}"
  end

end

class DeleteDocument < DatabaseRequestDefinition

  include QueryStringMixin

  def initialize(doc_id, rev_id)
    @doc_id = doc_id
    merge_query_items({:rev => rev_id})
  end

  def method
    'DELETE'
  end

  def sub_path
    "/#{@doc_id}"
  end

end
