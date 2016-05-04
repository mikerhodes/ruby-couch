require 'minitest/autorun'
require 'rubycouch'

class TransformsTest < Minitest::Test

  def setup
    @instance_root_uri = URI.parse('http://localhost:5984')
  end

  def test_adding_headers
    database_info = DatabaseInfo.new
    database_info.database_name = 'hola'
    database_info.merge_header_items({
      'X-Cloudant-User'=>'mikerhodes',
      'Another-Header'=>'Another Value'
      })
    template = RequestTransform.make_template(
      @instance_root_uri,
      database_info
    )

    assert_equal template.header_items['X-Cloudant-User'], 'mikerhodes'
    assert_equal template.header_items['Another-Header'], 'Another Value'
  end

end
