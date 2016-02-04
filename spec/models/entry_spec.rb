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

  context "the links hash attribute" do
    it "stores a serialized links hash" do
      entry = build(:entry)
      links = { "things" => [SecureRandom.uuid, SecureRandom.uuid] }

      entry.links = links
      entry.save!
      expect(entry.reload.links).to eq(links)
    end

    it "validates links is a hash" do
      entry = build(:entry, links: [:an, :array])

      expect(entry).not_to be_valid
    end

    it "validates links are specificed as an array" do
      entry = build(:entry, links: { "things" => { 'content_id' => SecureRandom.uuid } })

      expect(entry).not_to be_valid
    end

    it "strips links that aren't valid content IDs" do
      valid_content_id = SecureRandom.uuid
      entry = build(:entry, links: { "things" => [valid_content_id, 'invalid-content-id'] })

      expect(entry).to be_valid
      expect(entry.links["things"]).to eq([valid_content_id])
    end
  end

  context "#as_json" do
    let(:entry) { create(:entry, links: links) }
    let(:entry_json) { entry.as_json }
    let(:links) { { "things" => [SecureRandom.uuid, SecureRandom.uuid] } }

    [:base_path, :format, :title, :content_id].each do |attribute|
      it "includes the #{attribute} attribute" do
        expect(entry_json[attribute.to_s]).to eq(entry.public_send(attribute))
      end
    end

    [:id, :created_at, :updated_at].each do |attribute|
      it "excludes #{attribute} attribute" do
        expect(entry_json[attribute.to_s]).to be_nil
      end
    end

    it "expands linked items to a hash, including a key for 'content_id'" do
      expanded_links = {
        "things" => [
          { "content_id" => links['things'][0] },
          { "content_id" => links['things'][1] },
        ]
      }

      expect(entry_json['links']).to eq(expanded_links)
    end

    it "includes errors hash when the object is invalid" do
      entry = build(:entry, format: nil)

      expect(entry).to be_invalid
      expect(entry.as_json['errors']['format']).to include("can't be blank")
    end
  end

end
