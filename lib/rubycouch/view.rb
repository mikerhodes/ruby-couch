

class GetView

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleJsonResponseMixin

  def initialize(doc_id, view_name)
    doc_id = "_design/#{doc_id}" if !doc_id.start_with? '_design/'
    @doc_id = doc_id
    @view_name = view_name
  end

  def method
    'GET'
  end

  def sub_path
    "/#{@doc_id}/_view/#{@view_name}"
  end

end
