require 'net/http'
require 'net/https'
require 'uri'
require 'json'

require 'rubycouch/client'
require 'rubycouch/definitions'
require 'rubycouch/document'
require 'rubycouch/database'
require 'rubycouch/instance'

class RubyCouch
  def self.demo
    client = RubyClient.new(URI.parse('http://localhost:5984'))
    client.make_request(InstanceInfo.new)
  end
end


