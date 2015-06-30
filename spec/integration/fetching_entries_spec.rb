require 'rails_helper'

describe "Entry read API", :type => :request do

  context "request for entries of a particular format" do
    let!(:entries_for_answers) { create_list(:entry, 2, format: 'answer') }
    let!(:entry_for_news_article) { create(:entry, format: 'news-article') }

    it "should return entries for answers with the latest entry first" do
      get '/entries?format=answer'

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json")
      expect(response.cache_control).to eq({max_age: "900", public: true})

      expected_response_body = entries_for_answers.reverse.map { |entry| entry.as_json }
      expect(parsed_response_body).to eq(expected_response_body)
    end

    it "should return blank array in response if there are no entries for requested format" do
      get '/entries?format=speech'

      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq("application/json")

      expect(parsed_response_body).to eq([])
    end
  end

end
