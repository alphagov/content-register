module JsonHelper
  def put_json(path, attrs, headers = {})
    put path, attrs.to_json, {"CONTENT_TYPE" => "application/json"}.merge(headers)
  end

  def parsed_response_body
    JSON.parse(response.body)
  end
end

RSpec.configuration.include JsonHelper, :type => :request
