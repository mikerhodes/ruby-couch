require 'cgi'

##
# Common methods for request definition classes.
#
class RequestDefinition

  attr_reader :method
  attr_reader :path
  attr_reader :query_items

  def query_string
    query_items.map { |k,v|
      "#{CGI.escape(k)}=#{CGI.escape(v)}"
    }.join("&")
  end

end

##
# Marker for requests to the main instance endpoint, like _all_dbs
#
class InstanceRequestDefinition < RequestDefinition

end

class InstanceInfo < InstanceRequestDefinition

  def initialize
    @method = 'GET'
    @path = '/'
    @query_items = {}
  end

end

class AllDbs < InstanceRequestDefinition

  def initialize
    @method = 'GET'
    @path = '/_all_dbs'
    @query_items = {}
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
class DatabaseRequestDefinition < RequestDefinition

  attr_reader :sub_path

  def initialize
    @sub_path = ''
    @query_items = {}
  end

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

  def initialize
    @method = 'GET'
    @sub_path = '/'
    @query_items = {}
  end

end

class GetDocument < DatabaseRequestDefinition

  def initialize(doc_id)
    @method = 'GET'
    @doc_id = doc_id
    @query_items = {}
  end

  def rev_id=(rev_id)
    @query_items['rev'] = rev_id
  end

  def sub_path
    "/#{@doc_id}"
  end

end
