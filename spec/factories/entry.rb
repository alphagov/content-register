FactoryGirl.define do
  factory :entry do
    content_id { SecureRandom.uuid }
    sequence(:title) { |n| "Title of entry #{n}" }
    format 'news-article'
    base_path { "/#{title.parameterize}" }
  end
end
