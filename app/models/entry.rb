class Entry < ActiveRecord::Base

  PUBLIC_ATTRIBUTES = [:content_id, :title, :format, :base_path, :links]
  UUID_REGEX = %r{
    [a-f\d]{8}
    -
    [a-f\d]{4}
    -
    [1-5]   # Version: http://tools.ietf.org/html/rfc4122#section-4.1.3
    [a-f\d]{3}
    -
    [89ab]  # Variant: http://tools.ietf.org/html/rfc4122#section-4.1.1
    [a-f\d]{3}
    -
    [a-f\d]{12}
  }x

  validates_presence_of :content_id, :title, :format
  validates_format_of :content_id, with: /\A#{UUID_REGEX}\z/

  def as_json(options = {})
    super(options.merge(only: PUBLIC_ATTRIBUTES)).tap do |as_json_hash|
      as_json_hash['errors'] = errors.to_h.stringify_keys if errors.present?
    end
  end
end
