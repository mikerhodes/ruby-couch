require 'minitest/autorun'
require 'rubycouch'

class RubyCouchTest < Minitest::Test
  def test_simple_request
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    assert_equal "Welcome", client.make_request(InstanceInfo.new)['couchdb']
  end
end
