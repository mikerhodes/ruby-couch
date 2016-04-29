class InstanceInfo

  attr_reader :method
  attr_reader :path
  attr_reader :query

  def initialize
    @method = 'GET'
    @path = '/'
    @query = ''
  end

end

class AllDbs

  attr_reader :method
  attr_reader :path
  attr_reader :query

  def initialize
    @method = 'GET'
    @path = '/_all_dbs'
    @query = ''
  end

end

class DatabaseInfo

  attr_reader :method
  attr_accessor :path
  attr_reader :query

  def initialize
    @method = 'GET'
    @path = '/'
    @query = ''
  end

end
