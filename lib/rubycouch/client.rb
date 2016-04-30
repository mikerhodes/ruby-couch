require 'rubycouch/request'

class RubyClient

  def initialize(instance_root_uri)
    @instance_root_uri = instance_root_uri
    @requestor = Requestor.new()
  end

  def database(name)
    Database.new(self, name)
  end

  def make_request(request_definition)
    @requestor.response_json_for(make_template(request_definition))
  end

  def make_template(request_definition)
    rd = request_definition
    template = RequestTemplate.new(@instance_root_uri)
    template.method = rd.respond_to?(:method) ? rd.method : 'GET'
    template.path = rd.respond_to?(:path) ? rd.path : '/'
    template.query = rd.respond_to?(:query_string) ? rd.query_string : ''
    template
  end

end

class Database

  def initialize(client, name)
    @client = client
    @name = name
  end

  def make_request(request_definition)
    @client.make_request(request_definition)
  end

  def make_template(request_definition)
    if not request_definition.is_a?(DatabaseRequestDefinition) then
      raise 'Database requests must be DatabaseRequestDefinition subclasses'
    end
    request_definition.database_name = @name
    @client.make_template(request_definition)
  end

end
