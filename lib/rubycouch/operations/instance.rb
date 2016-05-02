
require 'rubycouch/operations/base'
require 'rubycouch/operations/responses'

class InstanceInfo

  include SimpleResponseMixin

  def method
    'GET'
  end

  def path
    '/'
  end

end

class AllDbs

  include SimpleResponseMixin

  def method
    'GET'
  end

  def path
    '/_all_dbs'
  end

end
