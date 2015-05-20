require 'rails_helper'

describe "Entry write API", :type => :request do
  let(:content_id) { SecureRandom.uuid }
  let(:entry_path) { "/entry/#{content_id}" }

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

    it "responds with a CREATED status" do
      put_json entry_path, data
      expect(response).to have_http_status(:created)
    end

    it "creates one entry" do
      expect {
        put_json entry_path, data
      }.to change {
        Entry.where(content_id: content_id).count
      }.from(0).to(1)
    end

    it "responds with the created entry as JSON in the body" do
      put_json entry_path, data
      expect(parsed_response_body).to eq(data)
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

    it "returns Unprocessable Entity status" do
      put_json entry_path, invalid_data
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "includes validation error messages in the response" do
      put_json entry_path, invalid_data

      expect(parsed_response_body).to include(invalid_data)
      expect(parsed_response_body['errors']['title']).to include("can't be blank")
    end
  end

  context "updating an existing entry" do
    let(:data) {
      {
        "content_id" => content_id,
        "title" => "VAT rates",
        "format" => "answer",
        "base_path" => "/vat-rates",
        "links" => { "things" => [SecureRandom.uuid, SecureRandom.uuid] },
      }
    }
    let(:updates) {
      {
        "title" => "Revised VAT rates",
        "base_path" => "/revised-vat-rates"
      }
    }

    before do
      put_json entry_path, data
    end

    it "responds with OK status" do
      put_json entry_path, updates
      expect(response).to have_http_status(:ok)
    end

    it "updates the exisiting entry" do
      put_json entry_path, updates

      updated_entry = Entry.where(content_id: content_id).first
      expect(updated_entry.title).to eq('Revised VAT rates')
      expect(updated_entry.base_path).to eq('/revised-vat-rates')
    end

    it "responds with the updated entry as JSON in the body" do
      put_json entry_path, updates
      expect(parsed_response_body).to eq(data.merge(updates))
    end
  end
end
