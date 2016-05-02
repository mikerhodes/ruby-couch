require 'rubycouch/operations/base'
require 'rubycouch/operations/responses'

class GetAttachment

  include QueryStringMixin
  include DatabaseRequestMixin

  def initialize(doc_id, attachment_name)
    @doc_id = doc_id
    @attachment_name = attachment_name
  end

  def method
    'GET'
  end

  def rev_id=(rev_id)
    merge_query_items({:rev => rev_id})
  end

  def sub_path
    "/#{@doc_id}/#{@attachment_name}"
  end

  ##
  # Need a custom response handler as response isn't going to be JSON.
  def response_handler
    lambda { |response|
      result = make_couch_response(response)
      def result.json
        raise "Attachments can't be automatically converted to JSON!"
      end
      result
    }
  end

end

##
# Create or update a document.
#
# For update, rev_id should be supplied. For create, obviously it shouldn't
# be.
class PutAttachment

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleJsonResponseMixin

  attr_reader :body
  attr_accessor :content_type

  def initialize(doc_id, attachment_name, content_type, body)
    @doc_id = doc_id
    @attachment_name = attachment_name
    @body = body
    @content_type = content_type
  end

  def method
    'PUT'
  end

  def rev_id=(rev_id)
    merge_query_items({:rev => rev_id})
  end

  def sub_path
    "/#{@doc_id}/#{@attachment_name}"
  end

end

class DeleteAttachment

  include QueryStringMixin
  include DatabaseRequestMixin
  include SimpleJsonResponseMixin

  def initialize(doc_id, attachment_name, rev_id)
    @doc_id = doc_id
    @attachment_name = attachment_name
    merge_query_items({:rev => rev_id})
  end

  def method
    'DELETE'
  end

  def sub_path
    "/#{@doc_id}/#{@attachment_name}"
  end

end
