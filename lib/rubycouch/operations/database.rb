
require 'rubycouch/operations/base'
require 'rubycouch/operations/responses'

class DatabaseInfo

  include DatabaseRequestMixin
  include SimpleResponseMixin
  include HeadersMixin

  def method
    'GET'
  end

  def sub_path
    '/'
  end

end

class AllDocs

  include DatabaseRequestMixin
  include ViewStreamingResponseMixin
  include QueryStringMixin

  def method
    'GET'
  end

  def sub_path
    '/_all_docs'
  end

end

##
# Create a database.
#
# Call like so: `client.database('hola').make_request(CreateDatabase.new)`
class CreateDatabase

  include DatabaseRequestMixin
  include SimpleResponseMixin
  include HeadersMixin

  def method
    'PUT'
  end

  def sub_path
    '/'
  end

end

##
# Delete a database.
#
# Call like so: `client.database('hola').make_request(DeleteDatabase.new)`
class DeleteDatabase

  include DatabaseRequestMixin
  include SimpleResponseMixin
  include HeadersMixin

  def method
    'DELETE'
  end

  def sub_path
    '/'
  end

end
