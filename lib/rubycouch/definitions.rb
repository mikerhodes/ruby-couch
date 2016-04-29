class RequestDefinition

  attr_reader :method
  attr_reader :path
  attr_reader :query_items

end

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
