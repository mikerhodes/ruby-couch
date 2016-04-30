require 'minitest/autorun'
require 'rubycouch'

class RubyCouchTest < Minitest::Test

  def test_simple_template
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    template = client.make_template(InstanceInfo.new)

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/', template.path
    assert_equal '', template.query
  end

  def test_all_dbs_template
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    template = client.make_template(AllDbs.new)

    assert_equal 'GET', template.method
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

    assert_equal 'GET', template.method
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

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal '', template.query
  end

  def test_get_document_with_revid_template
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    database = client.database('hola')
    get_document = GetDocument.new('test-doc-1')
    get_document.rev_id = '1-asdfsfd'
    template = database.make_template(get_document)

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal 'rev=1-asdfsfd', template.query
  end

  def test_not_db_request_raises_error_in_database_class
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    database = client.database('hola')

    assert_raises do
      template = database.make_template(AllDbs.new)
    end
  end

  def test_delete_document_with_revid_template
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    database = client.database('hola')
    delete_document = DeleteDocument.new('test-doc-1', '1-asdfsfd')
    template = database.make_template(delete_document)

    assert_equal 'DELETE', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal 'rev=1-asdfsfd', template.query
  end

end
