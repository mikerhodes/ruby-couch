require 'rubycouch/operations/base'
require 'rubycouch/operations/responses'

class GetAttachment

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleResponseMixin
  include HeadersMixin

  def initialize(doc_id, attachment_name)
    @doc_id = doc_id
    @attachment_name = attachment_name
  end

  def method
    'GET'
  end

  def rev=(value)
    merge_query_items({:rev => value.to_s})
  end

  def sub_path
    "/#{@doc_id}/#{@attachment_name}"
  end

end

##
# Create or update a document.
#
# For update, rev should be supplied. For create, obviously it shouldn't
# be.
#
# The body can be supplied as a binary blob or string etc. to `body`.
# Alternatively, supply a `body_stream` which is an IO-like object.
class PutAttachment

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleResponseMixin
  include HeadersMixin

  attr_accessor :body
  attr_accessor :body_stream
  attr_accessor :content_type

  def initialize(doc_id, attachment_name, content_type)
    @doc_id = doc_id
    @attachment_name = attachment_name
    @content_type = content_type
  end

  def method
    'PUT'
  end

  def rev=(value)
    merge_query_items({:rev => value.to_s})
  end

  def sub_path
    "/#{@doc_id}/#{@attachment_name}"
  end

end

class DeleteAttachment

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleResponseMixin
  include HeadersMixin

  def initialize(doc_id, attachment_name, rev)
    @doc_id = doc_id
    @attachment_name = attachment_name
    merge_query_items({:rev => rev})
  end

  def method
    'DELETE'
  end

  def sub_path
    "/#{@doc_id}/#{@attachment_name}"
  end

  def batch=(value)
    raise "batch value must be 'ok' or true" unless value or (value == 'ok')
    merge_query_items({:batch => 'ok'})
  end

end
