require 'minitest/autorun'
require 'rubycouch'

class RubyCouchTest < Minitest::Test

  def test_simple_template
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    template = client.make_template(InstanceInfo.new)
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/', template.path
    assert_equal '', template.query
  end

  def test_all_dbs_template
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    template = client.make_template(AllDbs.new)
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/_all_dbs', template.path
    assert_equal '', template.query
  end

  def test_simple_database_template
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    database = client.database('hola')
    template = database.make_template(DatabaseInfo.new)
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/', template.path
    assert_equal '', template.query
  end

  def test_simple_get_document_template
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    database = client.database('hola')
    template = database.make_template(GetDocument.new('test-doc-1'))
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal '', template.query
  end

end
