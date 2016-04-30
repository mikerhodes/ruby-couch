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

  def test_all_docs_database_template
    all_docs = AllDocs.new
    all_docs.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      all_docs
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/_all_docs', template.path
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

  def test_put_document_with_revid_template
    put_document = PutDocument.new('test-doc-1', '{"hello": "world"}')
    put_document.rev_id = '1-asdfsfd'
    put_document.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      put_document
    )

    assert_equal 'PUT', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 'application/json', template.content_type
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal 'rev=1-asdfsfd', template.query
    assert_equal '{"hello": "world"}', template.body
  end

  def test_put_document_without_revid_template
    put_document = PutDocument.new('test-doc-1', '{"hello": "world"}')
    put_document.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      put_document
    )

    assert_equal 'PUT', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 'application/json', template.content_type
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal '{"hello": "world"}', template.body
  end

  def test_put_document_with_contenttype_template
    put_document = PutDocument.new('test-doc-1', '{"hello": "world"}')
    put_document.database_name = 'hola'
    put_document.content_type = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      put_document
    )

    assert_equal 'PUT', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 'hola', template.content_type
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal '{"hello": "world"}', template.body
  end

  def test_view_get_template
    get_view = GetView.new('views101', 'latin_name')
    get_view.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      get_view
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/_design/views101/_view/latin_name', template.path
  end

end
