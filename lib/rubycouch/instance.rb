class InstanceInfo < InstanceRequestDefinition

  def method
    'GET'
  end

  def path
    '/'
  end

end

class AllDbs < InstanceRequestDefinition

  def method
    'GET'
  end

  def path
    '/_all_dbs'
  end

end
