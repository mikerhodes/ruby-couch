
class RequestTransform

  def self.make_template(base_uri, definition)
    template = RequestTemplate.new(base_uri)
    template.method = definition.respond_to?(:method) ? definition.method : 'GET'
    template.path = definition.respond_to?(:path) ? definition.path : '/'
    template.query = definition.respond_to?(:query_string) ? definition.query_string : ''
    template
  end

end
