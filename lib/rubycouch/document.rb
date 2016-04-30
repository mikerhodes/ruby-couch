

class GetDocument

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleJsonResponseMixin

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
class PutDocument

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleJsonResponseMixin

  attr_reader :body
  attr_accessor :content_type

  def initialize(doc_id, body)
    @doc_id = doc_id
    @body = body
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

class DeleteDocument

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleJsonResponseMixin

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
