
require 'rubycouch/operations/base'
require 'rubycouch/operations/responses'

##
# Get a document.
#
# There are a bunch of options this class doesn't yet cover.
class GetDocument

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleResponseMixin

  def initialize(doc_id)
    @doc_id = doc_id
  end

  def method
    'GET'
  end

  def rev_id=(rev_id)
    merge_query_items({:rev => rev_id})
  end

  def sub_path
    "/#{@doc_id}"
  end

end

##
# Create or update a document.
#
# For update, rev_id should be supplied. For create, obviously it shouldn't
# be.
#
# The body can be supplied as a string, or something JSON.dump() can process
# into a string. Alternatively, supply a `body_stream` which is an IO-like
# object.
class PutDocument

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleResponseMixin

  attr_reader :body
  attr_accessor :body_stream
  attr_accessor :content_type

  def initialize(doc_id)
    @doc_id = doc_id
    @content_type = 'application/json'
  end

  def body=(value)
    @body = if value.is_a? String then value else JSON.dump(value) end
  end

  def method
    'PUT'
  end

  def rev_id=(rev_id)
    merge_query_items({:rev => rev_id})
  end

  def sub_path
    "/#{@doc_id}"
  end

end

##
# Delete (tombstone) a document.
class DeleteDocument

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleResponseMixin

  def initialize(doc_id, rev_id)
    @doc_id = doc_id
    merge_query_items({:rev => rev_id})
  end

  def method
    'DELETE'
  end

  def sub_path
    "/#{@doc_id}"
  end

end
