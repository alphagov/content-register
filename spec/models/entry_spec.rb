require 'rails_helper'

describe Entry do

  context "validations" do
    it { should validate_presence_of(:content_id) }
    it { should allow_value('000b4062-8eaa-45ea-ba3c-7c6683a8cbbe').for(:content_id) }
    it { should_not allow_value('000B4062-8EAA-45EA-BA3C-7C6683A8CBBE').for(:content_id) }
    it { should_not allow_value('000-b40-628-eaa-45e-aba-3c7-c66-83a-8cbbe').for(:content_id) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:format) }
  end

  it "supports fields longer than 255 chars" do
    entry = build(:entry)
    entry.title = "x" * 300
    entry.base_path = "/" + "x" * 300
    entry.format = "f" * 300

    expect {
      entry.save!
    }.not_to raise_error
  end

  it "stores a serialized links hash" do
    entry = build(:entry)
    links = {
      "things" => [
        {
          "title" => "A thing",
          "base_path" => "/government/things/a-thing",
          "api_url" => "https://www.gov.uk/api/content/government/things/a-thing",
          "web_url" => "https://www.gov.uk/government/things/a-thing",
          "locale" => "en"
        }
      ]
    }

    entry.links = links
    entry.save!
    expect(entry.reload.links).to eq(links)
  end

  context "#as_json" do
    let(:entry_attributes) { attributes_for(:entry) }
    let(:entry_json) { create(:entry, entry_attributes).as_json }

    Entry::PUBLIC_ATTRIBUTES.each do |attribute|
      it "includes the #{attribute} attribute" do
        expect(entry_json[attribute.to_s]).to eq(entry_attributes[attribute])
      end
    end

    [:id, :created_at, :updated_at].each do |attribute|
      it "excludes #{attribute} attribute" do
        expect(entry_json[attribute.to_s]).to be_nil
      end
    end

    it "includes errors hash when the object is invalid" do
      entry = build(:entry, format: nil)

      expect(entry).to be_invalid
      expect(entry.as_json['errors']['format']).to include("can't be blank")
    end
  end

end
