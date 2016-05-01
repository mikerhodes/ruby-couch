require 'minitest/autorun'
require 'rubycouch/linereader'

class LineReaderTest < Minitest::Test

  def test_read_lines

    segments = [
      "part of a",
      " line\nand a second line\n",
      "a third line\n\nand a fo",
      "rth one",
      "\na fifth line\n"
    ]

    result = []
    LineReader.read_body MockResponse.new(segments) do |line|
      result.push(line)
    end

    assert_equal result, [
      "part of a line",
      "and a second line",
      "a third line",
      "and a forth one",
      "a fifth line"
    ]

  end

  def test_read_lines_no_trailing_newline

    segments = [
      "part of a",
      " line\nand a second line\n",
      "a third line\n\nand a fo",
      "rth one",
      "\na fifth line"
    ]

    result = []
    LineReader.read_body MockResponse.new(segments) do |line|
      result.push(line)
    end

    assert_equal result, [
      "part of a line",
      "and a second line",
      "a third line",
      "and a forth one",
      "a fifth line"
    ]

  end

  class MockResponse

    def initialize(segments)
      @segments = segments
    end

    def read_body
      @segments.each do |segment|
        yield segment
      end
    end

  end

end
