
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
# into a string.
class PutDocument

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleResponseMixin

  attr_reader :body
  attr_accessor :content_type

  def initialize(doc_id, body)
    @doc_id = doc_id
    @body = if body.is_a? String then body else JSON.dump(body) end
    @content_type = 'application/json'
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
