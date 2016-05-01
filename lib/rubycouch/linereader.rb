##
# Class maintaining a state machine for iterating lines in a stream.
#
# Does not callback for empty lines


class LineReader

  ##
  # `response` is something with a `read_body` ala HTTP responses
  def self.read_body(response)
    @current_line_buffer = ''
    response.read_body do |segment|
      segment.each_char do |c|
        if c == "\n"
          if not @current_line_buffer.strip.empty?
            yield @current_line_buffer
          end
          @current_line_buffer = ''
        else
          @current_line_buffer += c
        end
      end
    end

    # And whatever is left, if there wasn't a trailing newline
    if not @current_line_buffer.strip.empty?
      yield @current_line_buffer
    end
  end


end
