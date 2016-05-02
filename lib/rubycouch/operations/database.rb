
require 'rubycouch/operations/base'
require 'rubycouch/operations/responses'

class DatabaseInfo

  include DatabaseRequestMixin
  include SimpleResponseMixin

  def method
    'GET'
  end

  def sub_path
    '/'
  end

end

class AllDocs

  include DatabaseRequestMixin
  include ViewStreamingResponseMixin
  include QueryStringMixin

  def method
    'GET'
  end

  def sub_path
    '/_all_docs'
  end

end
