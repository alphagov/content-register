class Entry < ActiveRecord::Base
  serialize :links, Hash

  PUBLIC_ATTRIBUTES = [:content_id, :title, :format, :base_path]
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
  validate :validate_links_hash_format

  def as_json(options = {})
    super(options.merge(only: PUBLIC_ATTRIBUTES)).tap do |as_json_hash|
      as_json_hash['errors'] = errors.to_h.stringify_keys if errors.present?
      as_json_hash['links'] = expanded_links
    end
  end

  def links=(links_hash)
    super unless links_hash.is_a?(Hash)

    clean_hash = {}
    links_hash.each do |link_type, array_of_content_ids|
      if array_of_content_ids.is_a?(Array)
        array_of_content_ids.select! { |id| id =~ /\A#{UUID_REGEX}\z/ }
      end

      clean_hash[link_type] = array_of_content_ids
    end

    super(clean_hash)
  end

private

  def expanded_links
    links.each_with_object({}) do |(key, content_ids), hash|
      hash[key] = content_ids.map {|content_id| { 'content_id' => content_id} }
    end
  end

  def validate_links_hash_format
    unless links.is_a?(Hash) && links_values_are_valid_format?
      errors.add(:links, 'is not a valid. See content-register doc/input_example.json for valid format')
    end
  end

  def links_values_are_valid_format?
    links.all? do |(key, value)|
      value.is_a?(Array) && value.all? { |content_id| content_id =~ /\A#{UUID_REGEX}\z/ }
    end
  end
end
