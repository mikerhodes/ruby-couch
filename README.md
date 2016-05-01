# A more HTTP-like CouchDB client for Ruby

This client library is designed to be more familiar to those used to CouchDB's HTTP interface, as well as being a safe and efficient method of interacting with Couch. 

It's based on the idea of _templates_ rather than _method calls_. Instead of calling a method with arguments, one makes a request by filling in a template and getting the client to make the request:

```ruby
require 'rubycouch'

client = CouchClient.new(URI.parse('http://localhost:5984'))
response = client.make_request(AllDbs.new)
response.json
# => ["_replicator","_users","animaldb",...]
```

This is intended to make the calls being made over the network more explicit, but also has the side-effect of being a bit like SQL, where one composes a query and then makes it.

## Incompleteness

Right now the library is basically a demo. However, it should be fairly obvious how to add operations and at least test their transformation into request templates, so I'm more than happy to accept PRs if the idea of the library intrigues you and you want to use it for your own projects.

## Benefits

There are a bunch of benefits to the template approach.

Firstly, as intimated, it makes the requests to the database crystal-clear. One thing I've noticed when supporting people using client libraries for different systems is that, often, it's a struggle to work out what's going on under the hood. Why is such-and-such call taking so long? Often it turns out that one method call actually equates to several HTTP requests.

Secondly, taking this approach makes it very simple to take HTTP docs and translate them to the library, or to transfer knowledge from making raw HTTP calls to being a little helped by a library:

```ruby
get_document = GetDocument.new('aardvark')
get_document.rev_id = '1-asdfsfd'  # ?rev_id=1-asdfsfd
client.database('animaldb').make_request(get_document).json
# => {"_id"=>"aardvark", "min_weight"=>40, "_rev"=>... }

put_document = PutDocument.new('test-doc-1', '{"hello": "world"}')
put_document.rev_id = '1-asdfsfd'  # ?rev_id=1-asdfsfd
client.database('animaldb').make_request(put_document).json
```

As a developer there are some further benefits. It makes things easier to test, because one can test that a set of calls create the right description of a HTTP request separately from testing that the description is executed correctly. 

It also means that code naturally falls into small chunks. Normally, a client object would have dozens of methods. In this library, all the client does is maintain high-level connection parameters, such as the root of the CouchDB instance and the credentials to use over HTTP Basic Authentication.

At some point, this will hopefully make it simpler to use different HTTP libraries, but for now it's just `Net:HTTP`.

## The API

I'll document the full API at some point, but for now, check the source code in the `lib/rubycoucy/operations` folder for a list of the operations you can do. Most operations don't actually have a full method compliment for the query parameters they accept. Instead, use `merge_query_params` on the operation, for example, `merge_query_params({:include_docs=>true})`.

Some things deserve a couple more notes.

### Views

Views can be called in either a simple or streaming manner. Use streaming for retrieving larger result sets, as the code avoids buffering the response in memory.

The simple way gives you back a response with all the data inside it:

```ruby
client.database('animaldb')
    .make_request(GetView.new('views101', 'latin_name'))
    .json
# =>
# "{"total_rows":5,"offset":0,"rows":[
# {"id":"kookaburra","key":"Dacelo novaeguineae","value":19},
# {"id":"snipe","key":"Gallinago gallinago","value":19},
# {"id":"llama","key":"Lama glama","value":10},
# {"id":"badger","key":"Meles meles","value":11},
# {"id":"aardvark","key":"Orycteropus afer","value":16}
# ]}
```

In the streaming version, one provides a callback as a Proc or Lambda. The Proc is called for every row in the result set. This consumes each row, so by the time you get the result of the `make_request` call, the `rows` field is empty:

```ruby
get_view = GetView.new('views101', 'latin_name')
get_view.row_callback = lambda { |row, idx|
    puts sprintf("  %d: %s", idx, row)
    # => 0: {"id"=>"kookaburra", "key"=>"Dacelo novaeguineae","value":19}
    # and so on. `row` is always decoded JSON.
}
client.database('animaldb').make_request(get_view).json
# => {"total_rows":5,"offset":0,"rows":[]}
```
