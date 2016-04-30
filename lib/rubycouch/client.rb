require 'rubycouch/request'
require 'rubycouch/requesttransform'

class CouchClient

  def initialize(instance_root_uri)
    @instance_root_uri = instance_root_uri
    @requestor = Requestor.new()
  end

  def database(name)
    Database.new(self, name)
  end

  def make_request(request_definition)
    template = RequestTransform.make_template(
      @instance_root_uri,
      request_definition
    )
    @requestor.response_json_for(template)
  end

end

class Database

  def initialize(client, name)
    @client = client
    @name = name
  end

  def make_request(request_definition)
    if not request_definition.is_a?(DatabaseRequestDefinition) then
      raise 'Database requests must be DatabaseRequestDefinition subclasses'
    end
    request_definition.database_name = @name
    @client.make_request(request_definition)
  end

end
