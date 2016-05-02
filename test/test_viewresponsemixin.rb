require 'minitest/autorun'
require 'rubycouch/operations/responses'

class ViewResponseMixin < Minitest::Test

  def test_streaming_response_empty_result_set

    couch_response = %q(
    {"total_rows":0,"offset":0,"rows":[
    ]}
    )

    actual_rows, non_row_body = process_response(couch_response)

    # Asserts
    assert_equal JSON.parse(couch_response)['rows'], actual_rows
    assert_equal '{"total_rows":0,"offset":0,"rows":[]}', non_row_body

  end

  def test_streaming_response_non_reduce

    couch_response = %q(
    {"total_rows":5,"offset":0,"rows":[
    {"id":"kookaburra","key":"Dacelo novaeguineae","value":19},
    {"id":"snipe","key":"Gallinago gallinago","value":19},
    {"id":"llama","key":"Lama glama","value":10},
    {"id":"badger","key":"Meles meles","value":11},
    {"id":"aardvark","key":"Orycteropus afer","value":16}
    ]}
    )

    actual_rows, non_row_body = process_response(couch_response)

    # Asserts
    assert_equal JSON.parse(couch_response)['rows'], actual_rows
    assert_equal '{"total_rows":5,"offset":0,"rows":[]}', non_row_body

  end

  def test_streaming_response_reduced

    couch_response = %q(
    {"rows":[
    {"key":"Dacelo novaeguineae","value":1},
    {"key":"Gallinago gallinago","value":1},
    {"key":"Lama glama","value":1},
    {"key":"Meles meles","value":1},
    {"key":"Orycteropus afer","value":1}
    ]}
    )

    actual_rows, non_row_body = process_response(couch_response)

    # Asserts
    assert_equal JSON.parse(couch_response)['rows'], actual_rows
    assert_equal '{"rows":[]}', non_row_body

  end

  ##
  # The boiler-plate of setting up the mocks and processing the response
  def process_response(couch_response)

    # Should be asked to read lines from mocked_response
    line_reader_class = Class.new do
      def self.read_body(response)
        response.each do |line|
          yield line
        end
      end
    end

    # Collect the rows found
    rows = []
    callback = lambda { |line, idx|
      rows.push line
    }

    # Finally, set up the mixin class
    view_mixin = Class.new do
      include ViewStreamingResponseMixin
    end.new
    view_mixin.row_callback = callback

    # Run the streaming method
    non_row_body = view_mixin.ViewStreamingResponseMixin_stream_response(
      line_reader_class, couch_response.lines, callback)

    return rows, non_row_body

  end

end
