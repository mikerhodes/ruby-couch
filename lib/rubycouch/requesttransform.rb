
class RequestTransform

  def self.make_template(base_uri, definition)
    template = RequestTemplate.new(base_uri)
    template.method = definition.respond_to?(:method) ? definition.method : 'GET'
    template.path = definition.respond_to?(:path) ? definition.path : '/'
    template.query = definition.respond_to?(:query_string) ? definition.query_string : ''
    template.body = definition.body if definition.respond_to?(:body)
    template.body_stream = definition.body_stream if definition.respond_to?(:body_stream)
    template.content_type = definition.content_type if definition.respond_to?(:content_type)
    template.response_handler = definition.response_handler if definition.respond_to?(:response_handler)
    template.header_items = definition.header_items if definition.respond_to?(:header_items)
    template
  end

end
