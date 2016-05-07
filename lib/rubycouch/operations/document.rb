require 'json'

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
  include HeadersMixin

  def initialize(doc_id)
    @doc_id = doc_id
  end

  def method
    'GET'
  end

  def sub_path
    "/#{@doc_id}"
  end

  # Params

  def attachments=(value)
    merge_query_items({:attachments => !!value})
  end

  def att_encoding_info=(value)
    merge_query_items({:att_encoding_info => !!value})
  end

  def atts_since=(arr)
    merge_query_items({:atts_since => JSON.dump(arr)})
  end

  def conflicts=(value)
    merge_query_items({:conflicts => !!value})
  end

  def deleted_conflicts=(value)
    merge_query_items({:deleted_conflicts => !!value})
  end

  def latest=(value)
    merge_query_items({:latest => !!value})
  end

  def local_seq=(value)
    merge_query_items({:local_seq => !!value})
  end

  def meta=(value)
    merge_query_items({:meta => !!value})
  end

  def open_revs=(arr_or_all)
    value = arr_or_all == 'all' ? 'all' : JSON.dump(arr_or_all)
    merge_query_items({:open_revs => value})
  end

  def rev=(value)
    merge_query_items({:rev => value.to_s})
  end

  def revs=(value)
    merge_query_items({:revs => !!value})
  end

  def revs_info=(value)
    merge_query_items({:revs_info => !!value})
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
  include HeadersMixin

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

  def rev=(value)
    merge_query_items({:rev => value.to_s})
  end

  def batch=(value)
    raise "batch value must be 'ok' or true" unless value or (value == 'ok')
    merge_query_items({:batch => 'ok'})
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
  include HeadersMixin

  def initialize(doc_id, rev)
    @doc_id = doc_id
    merge_query_items({:rev => rev.to_s})
  end

  def method
    'DELETE'
  end

  def sub_path
    "/#{@doc_id}"
  end

  def batch=(value)
    raise "batch value must be 'ok' or true" unless value or (value == 'ok')
    merge_query_items({:batch => 'ok'})
  end

end
