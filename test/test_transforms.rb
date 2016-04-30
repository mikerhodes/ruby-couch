require 'minitest/autorun'
require 'rubycouch'

class TransformsTest < Minitest::Test

  def setup
    @instance_root_uri = URI.parse('http://localhost:5984')
  end

  def test_simple_template
    template = RequestTransform.make_template(
      @instance_root_uri,
      InstanceInfo.new
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/', template.path
    assert_equal '', template.query
  end

  def test_all_dbs_template
    template = RequestTransform.make_template(
      @instance_root_uri,
      AllDbs.new
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/_all_dbs', template.path
    assert_equal '', template.query
  end

  def test_simple_database_template
    database_info = DatabaseInfo.new
    database_info.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      database_info
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/', template.path
    assert_equal '', template.query
  end

  def test_simple_get_document_template
    get_document = GetDocument.new('test-doc-1')
    get_document.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      get_document
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal '', template.query
  end

  def test_get_document_with_revid_template
    get_document = GetDocument.new('test-doc-1')
    get_document.database_name = 'hola'
    get_document.rev_id = '1-asdfsfd'
    template = RequestTransform.make_template(
      @instance_root_uri,
      get_document
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal 'rev=1-asdfsfd', template.query
  end

  def test_not_db_request_raises_error_in_database_class
    client = CouchClient.new(URI.parse('http://localhost:5984'))
    database = client.database('hola')

    assert_raises do
      template = database.make_request(AllDbs.new)
    end
  end

  def test_delete_document_with_revid_template
    delete_document = DeleteDocument.new('test-doc-1', '1-asdfsfd')
    delete_document.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      delete_document
    )

    assert_equal 'DELETE', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal 'rev=1-asdfsfd', template.query
  end

end
