require 'rubycouch/request'

class RubyClient

  def initialize(instance_root_uri)
    @instance_root_uri = instance_root_uri
  end

  def database(name)
    Database.new(self, name)
  end

  def make_request(request_definition)
    requestor = Requestor.new()
    requestor.response_json_for(make_template(request_definition))
  end

  def make_template(request_definition)
    template = RequestTemplate.new(@instance_root_uri)
    template.method = request_definition.method
    template.path = request_definition.path
    template.query = request_definition.query
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

  def augment_definition!(request_definition)
    # A bit of cleaning to make constructing the path easier
    path = request_definition.path
    path = path[1..-1] if path.start_with? '/'

    request_definition.path = "/#{@name}/#{path}"
    request_definition
  end

  def make_template(request_definition)
    request_definition.database_name = @name
    @client.make_template(request_definition)
  end

end
