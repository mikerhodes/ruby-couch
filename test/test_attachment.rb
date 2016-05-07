require 'minitest/autorun'
require 'rubycouch'

class TransformsTest < Minitest::Test

  def setup
    @instance_root_uri = URI.parse('http://localhost:5984')
  end

  def test_simple_get_attachment_template
    get_attachment = GetAttachment.new('test-doc-1', 'my-att.blah')
    get_attachment.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      get_attachment
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1/my-att.blah', template.path
    assert_equal '', template.query
  end

  def test_get_attachment_with_revid_template
    get_attachment = GetAttachment.new('test-doc-1', 'my-att.blah')
    get_attachment.database_name = 'hola'
    get_attachment.rev = '1-asdfsfd'
    template = RequestTransform.make_template(
      @instance_root_uri,
      get_attachment
    )

    assert_equal 'GET', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1/my-att.blah', template.path
    assert_equal 'rev=1-asdfsfd', template.query
  end

  def test_delete_attachment_with_revid_template
    delete_att = DeleteAttachment.new('test-doc-1', 'my-att.blah', '1-asdfsfd')
    delete_att.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      delete_att
    )

    assert_equal 'DELETE', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1/my-att.blah', template.path
    assert_equal 'rev=1-asdfsfd', template.query
  end

  def test_delete_document_with_batch_template
    delete_att = DeleteAttachment.new('test-doc-1', 'my-att.blah', '1-asdfsfd')
    delete_att.database_name = 'hola'
    delete_att.batch = 'ok'
    template = RequestTransform.make_template(
      @instance_root_uri,
      delete_att
    )

    assert_equal 'DELETE', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1', template.path
    assert_equal 'rev=1-asdfsfd&batch=ok', template.query
  end

  def test_put_attachment_with_revid_template
    put_attachment = PutAttachment.new(
      'test-doc-1', 'my-att.blah', 'text/plain')
    put_attachment.body = 'Hello world!'
    put_attachment.rev = '1-asdfsfd'
    put_attachment.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      put_attachment
    )

    assert_equal 'PUT', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 'text/plain', template.content_type
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1/my-att.blah', template.path
    assert_equal 'rev=1-asdfsfd', template.query
    assert_equal 'Hello world!', template.body
  end

  def test_put_attachment_without_revid_template
    put_attachment = PutAttachment.new(
      'test-doc-1', 'my-att.blah', 'text/plain')
    put_attachment.body = 'Hello world!'
    put_attachment.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      put_attachment
    )

    assert_equal 'PUT', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 'text/plain', template.content_type
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1/my-att.blah', template.path
    assert_equal 'Hello world!', template.body
  end

  def test_put_attachment_with_stream_template
    put_attachment = PutAttachment.new(
      'test-doc-1', 'my-att.blah', 'text/plain')
    put_attachment.body_stream = StringIO.new('Hello world!')
    put_attachment.database_name = 'hola'
    template = RequestTransform.make_template(
      @instance_root_uri,
      put_attachment
    )

    assert_equal 'PUT', template.method
    assert_equal 'http', template.scheme
    assert_equal 'localhost', template.host
    assert_equal 'text/plain', template.content_type
    assert_equal 5984, template.port
    assert_equal '/hola/test-doc-1/my-att.blah', template.path
    assert_equal nil, template.body
    assert_equal 'Hello world!', template.body_stream.read()
  end

end
