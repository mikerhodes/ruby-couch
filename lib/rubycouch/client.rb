require 'rubycouch/request'
require 'rubycouch/requesttransform'

class CouchClient

  ##
  # Initialise the client with a Couch root URI.
  #
  # :param instance_root_uri Something like 'http://localhost:5984'
  def initialize(instance_root_uri)
    @instance_root_uri = instance_root_uri
    @requestor = Requestor.new()
  end

  ##
  # Add authentication to requests made by this client.
  def basic_auth(username, password)
    @basic_auth = {:username => username, :password => password}
  end

  def database(name)
    Database.new(self, name)
  end

  def make_request(request_definition, &block)
    template = RequestTransform.make_template(
      @instance_root_uri,
      request_definition
    )
    template.basic_auth = @basic_auth if @basic_auth
    @requestor.response_for(template, block)
  end

end

class Database

  def initialize(client, name)
    @client = client
    @name = name
  end

  def make_request(request_definition, &block)
    if not request_definition.respond_to?(:database_name=) then
      raise 'Database requests must respond to :database_name'
    end
    request_definition.database_name = @name
    @client.make_request(request_definition, &block)
  end

end
