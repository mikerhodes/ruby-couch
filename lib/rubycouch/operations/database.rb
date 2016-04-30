
require 'rubycouch/operations/base'

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

class AllDocs

  include DatabaseRequestMixin
  include SimpleJsonResponseMixin
  include QueryStringMixin

  def method
    'GET'
  end

  def sub_path
    '/_all_docs'
  end

end
