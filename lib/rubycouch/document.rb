

class GetDocument

  include QueryStringMixin
  include DatabaseRequestMixin

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

class DeleteDocument

  include QueryStringMixin
  include DatabaseRequestMixin

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
