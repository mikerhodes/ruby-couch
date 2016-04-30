require 'net/http'
require 'net/https'
require 'uri'
require 'json'

require 'rubycouch/client'
require 'rubycouch/operations/base'
require 'rubycouch/operations/database'
require 'rubycouch/operations/document'
require 'rubycouch/operations/instance'
require 'rubycouch/operations/view'

class RubyCouch
  def self.demo
    client = CouchClient.new(URI.parse('http://localhost:5984'))

    print "====== InstanceInfo ======\n"
    print client.make_request(InstanceInfo.new)

    print "\n\n====== AllDbs ======\n"
    print client.make_request(AllDbs.new)

    database = client.database('animaldb')

    print "\n\n====== animaldb -- DatabaseInfo ======\n"
    print database.make_request(DatabaseInfo.new)

    print "\n\n====== animaldb -- AllDocs ======\n"
    print database.make_request(AllDocs.new)

    print "\n\n====== animaldb -- GetDocument(elephant) ======\n"
    print database.make_request(GetDocument.new('elephant'))

    print "\n\n====== animaldb -- GetView(view101) ======\n"
    print database.make_request(GetView.new('views101', 'latin_name'))

    print "\n\n====== animaldb -- GetView Reduced(view101) ======\n"
    get_view = GetView.new('views101', 'latin_name_count')
    get_view.merge_query_items({:reduce => true})
    print database.make_request(get_view)

    print "\n\ndone.\n"
  end
end


