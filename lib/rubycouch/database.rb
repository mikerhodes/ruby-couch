

class DatabaseInfo

  include DatabaseRequestMixin
  include SimpleJsonResponseMixin

  def method
    'GET'
  end

  def sub_path
    '/'
  end

end
