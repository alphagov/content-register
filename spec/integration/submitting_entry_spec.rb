require 'rails_helper'

describe "Entry write API", :type => :request do
  let(:content_id) { SecureRandom.uuid }

  context "creating a new entry with valid attributes" do
    let(:data) {
      {
        "content_id" => content_id,
        "title" => "VAT rates",
        "format" => "answer",
        "base_path" => "/vat-rates",
        "links" => {},
      }
    }

    before do
      put_json entry_path(content_id), data
    end

    it "responds with a CREATED status" do
      expect(response).to have_http_status(:created)
    end

    it "creates an entry" do
      expect(Entry.where(content_id: content_id).count).to eq(1)
    end

    it "responds with the created entry as JSON in the body" do
      entry = Entry.find_by(content_id: content_id)
      expect(parsed_response_body).to eq(entry.as_json)
    end
  end

  context "attempting to create with invalid attributes" do
    let(:invalid_data) {
      {
        "content_id" => content_id,
        "title" => "",
        "format" => "answer",
        "base_path" => "/vat-rates"
      }
    }

    before do
      put_json entry_path(content_id), invalid_data
    end

    it "returns Unprocessable Entity status" do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "includes validation error messages in the response" do
      expect(parsed_response_body).to include(invalid_data)
      expect(parsed_response_body['errors']['title']).to include("can't be blank")
    end
  end

  context "updating an existing entry" do
    let(:entry) { create(:entry) }
    let(:updates) {
      {
        "title" => "Revised VAT rates",
        "base_path" => "/revised-vat-rates"
      }
    }

    before do
      put_json entry_path(entry.content_id), updates
    end

    it "responds with OK status" do
      expect(response).to have_http_status(:ok)
    end

    it "updates the exisiting entry" do
      entry.reload
      expect(entry.title).to eq('Revised VAT rates')
      expect(entry.base_path).to eq('/revised-vat-rates')
    end

    it "responds with the updated entry as JSON in the body" do
      expect(parsed_response_body).to eq(entry.reload.as_json)
    end
  end
end
