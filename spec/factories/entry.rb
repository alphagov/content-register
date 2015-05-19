FactoryGirl.define do
  factory :entry do
    content_id { SecureRandom.uuid }
    sequence(:title) { |n| "Title of entry #{n}" }
    format 'news-article'
    base_path { "/#{title.parameterize}" }
    links {
      {
        'things' => [
          {
            "title" => "A thing",
            "base_path" => "/government/things/a-thing",
            "api_url" => "https://www.gov.uk/api/content/government/things/a-thing",
            "web_url" => "https://www.gov.uk/government/things/a-thing",
            "locale" => "en"
          }
        ]
      }
    }
  end
end
