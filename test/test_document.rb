require 'minitest/autorun'
require 'rubycouch'

class TransformsTest < Minitest::Test

  def setup
    @instance_root_uri = URI.parse('http://localhost:5984')
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
    get_document.rev = '1-asdfsfd'
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

  def test_get_document_with_all_params
    get_document = GetDocument.new('test-doc-1')
    get_document.database_name = 'hola'
    get_document.attachments = true
    get_document.att_encoding_info = true
    get_document.atts_since = ['1-werewr', '34-sdfd']
    get_document.conflicts = true
    get_document.deleted_conflicts = true
    get_document.latest = true
    get_document.local_seq = true
    get_document.meta = true
    get_document.open_revs = 'all'
    get_document.rev = '1-asdfsfd'
    get_document.revs = true
    get_document.revs_info = true
    template = RequestTransform.make_template(
      @instance_root_uri,
      get_document
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal [
      'attachments=true',
      'att_encoding_info=true',
      'atts_since=%5B%221-werewr%22%2C%2234-sdfd%22%5D',
      'conflicts=true',
      'deleted_conflicts=true',
      'latest=true',
      'local_seq=true',
      'meta=true',
      'open_revs=all',
      'rev=1-asdfsfd',
      'revs=true',
      'revs_info=true'].join('&'), template.query
  end

  def test_get_document_with_open_revs_array
    get_document = GetDocument.new('test-doc-1')
    get_document.database_name = 'hola'
    get_document.open_revs = ['1-wefdfsdf', '34-wererer']
    template = RequestTransform.make_template(
      @instance_root_uri,
      get_document
    )
    assert_equal(
      'open_revs=%5B%221-wefdfsdf%22%2C%2234-wererer%22%5D',
      template.query)
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

  def test_delete_document_with_batch_template
    delete_document = DeleteDocument.new('test-doc-1', '1-asdfsfd')
    delete_document.database_name = 'hola'
    delete_document.batch = 'ok'
    template = RequestTransform.make_template(
      @instance_root_uri,
      delete_document
    )

    assert_equal 'DELETE', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal 'rev=1-asdfsfd&batch=ok', template.query
  end

  def test_put_document_with_revid_template
    put_document = PutDocument.new('test-doc-1')
    put_document.body = '{"hello": "world"}'
    put_document.rev = '1-asdfsfd'
    put_document.batch = true
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
    assert_equal 'rev=1-asdfsfd&batch=ok', template.query
    assert_equal '{"hello": "world"}', template.body
  end

  def test_put_document_without_revid_template
    put_document = PutDocument.new('test-doc-1')
    put_document.body = '{"hello": "world"}'
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
    put_document = PutDocument.new('test-doc-1')
    put_document.body = '{"hello": "world"}'
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

  def test_put_document_with_stream_template
    put_document = PutDocument.new('test-doc-1')
    put_document.body_stream = StringIO.new('{"hello": "world"}')
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
    assert_equal nil, template.body
    assert_equal '{"hello": "world"}', template.body_stream.read()
  end

end
