Gem::Specification.new do |s|
  s.name        = 'rubycouch'
  s.version     = '0.0.0'
  s.date        = '2016-04-29'
  s.summary     = "A simple CouchDB client"
  s.description = "A CouchDB client that helps you make requests without fuss."
  s.authors     = ["Mike Rhodes"]
  s.email       = 'mike.rhodes@dx13.co.uk'
  s.files       = [
    'lib/rubycouch.rb', 'lib/rubycouch/request.rb',
    'lib/rubycouch/client.rb', 'lib/rubycouch/definitions.rb',
    'lib/rubycouch/instance.rb', 'lib/rubycouch/database.rb',
    'lib/rubycouch/document.rb']
  s.homepage    =
    'https://github.com/mikerhodes/ruby-couch'
  s.license       = 'Apache 2'
end
