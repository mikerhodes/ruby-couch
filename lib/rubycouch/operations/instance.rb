require 'rubycouch/operations/base'

class InstanceInfo

  include SimpleJsonResponseMixin

  def method
    'GET'
  end

  def path
    '/'
  end

end

class AllDbs

  include SimpleJsonResponseMixin

  def method
    'GET'
  end

  def path
    '/_all_dbs'
  end

end
