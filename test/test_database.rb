require 'minitest/autorun'
require 'rubycouch'

class TransformsTest < Minitest::Test

  def setup
    @instance_root_uri = URI.parse('http://localhost:5984')
  end

  def test_create_database
    create = CreateDatabase.new
    create.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      create
    )

    assert_equal 'PUT', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/', template.path
    assert_equal '', template.query
  end

  def test_delete_database
    delete_database = DeleteDatabase.new
    delete_database.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      delete_database
    )

    assert_equal 'DELETE', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/', template.path
    assert_equal '', template.query
  end

end
