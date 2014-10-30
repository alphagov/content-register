FactoryGirl.define do
  factory :entry do
    content_id { SecureRandom.uuid }
    title 'VAT rates'
    format 'news-article'
    base_path '/vat-rates'
  end
end
