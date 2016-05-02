require 'net/http'
require 'net/https'
require 'uri'
require 'json'

require 'rubycouch/client'
require 'rubycouch/operations/attachment'
require 'rubycouch/operations/base'
require 'rubycouch/operations/database'
require 'rubycouch/operations/document'
require 'rubycouch/operations/instance'
require 'rubycouch/operations/view'

class RubyCouch
  def self.demo
    client = CouchClient.new(URI.parse('http://localhost:5984'))

    # Add basic authentication with:
    # client.basic_auth 'username', 'password'

    print "====== InstanceInfo ======\n"
    print client.make_request(InstanceInfo.new).json

    print "\n\n====== AllDbs ======\n"
    print client.make_request(AllDbs.new).json

    database = client.database('animaldb')

    print "\n\n====== animaldb -- DatabaseInfo ======\n"
    print database.make_request(DatabaseInfo.new).json

    print "\n\n====== animaldb -- AllDocs ======\n"
    print database.make_request(AllDocs.new).json

    print "\n\n====== animaldb -- GetDocument(elephant) ======\n"
    print database.make_request(GetDocument.new('elephant')).json

    print "\n\n====== animaldb -- GetView(view101) ======\n"
    print database.make_request(GetView.new('views101', 'latin_name')).json

    # Using the callback/iter approach means the entire response
    # isn't stored into memory. Instead, result rows are passed to
    # the called as they arrive off the wire, and the return value
    # from make request doesn't contain them, only an empty array.
    print "\n\n====== animaldb -- GetView(view101) iter ======\n"
    get_view = GetView.new('views101', 'latin_name')
    get_view.merge_query_items({:include_docs => true})
    puts "Rows:"
    get_view.row_callback = lambda { |row, idx|
        puts sprintf("  %d: %s", idx, row)
    }
    return_value = database.make_request(get_view)
    puts sprintf("Return value:\n  %s", return_value.json)

    print "\n\n====== animaldb -- GetView Reduced(view101) ======\n"
    get_view = GetView.new('views101', 'latin_name_count')
    get_view.merge_query_items({:reduce => true})
    print database.make_request(get_view).json

    # This database probably doesn't exist so it'll give an error
    database = client.database('animaldsdfsdfb')
    print "\n\n====== animaldsdfsdfb -- DatabaseInfo ======\n"
    print database.make_request(DatabaseInfo.new).json

    print "\n\ndone.\n"
  end
end


