require 'rails_helper'

describe "Consuming messages from the publishing-api message queue", :message_queue do

  start_message_consumer_around_all

  let(:message_data) {
    {
      "base_path" => "/vat-rates",
      "content_id" => SecureRandom.uuid,
      "title" => "VAT rates",
      "description" => "Current VAT rates",
      "format" => "answer",
      "locale" => "en",
      "need_ids" => ["100123", "100124"],
      "public_updated_at" => "2014-05-14T13:00:06Z",
      "updated_at" => "2014-05-14T13:05:06Z",
      "update_type" => "major",
      "publishing_app" => "publisher",
      "rendering_app" => "frontend",
      "details" => {
        "body" => "<p>Some body text</p>\n",
      },
      "routes" => [
        { "path" => "/vat-rates", "type" => 'exact' }
      ],
    }
  }

  it "creates an entry for the content item" do
    put_message_on_queue(message_data)

    eventually do
      expect(Entry.count).to eq(1)
      e = Entry.find_by!(:content_id => message_data["content_id"])
      expect(e).to be
      expect(e.title).to eq("VAT rates")
      expect(e.format).to eq("answer")
      expect(e.base_path).to eq("/vat-rates")
    end
  end

  it "updates an entry with a matching content Id" do
    entry = create(:entry,
      :content_id => message_data["content_id"],
      :title => "Old VAT rates",
      :format => 'old-article',
      :base_path => '/old-vat-rates',
    )

    put_message_on_queue(message_data)

    eventually do
      entry.reload
      expect(entry.title).to eq("VAT rates")
      expect(entry.format).to eq("answer")
      expect(entry.base_path).to eq("/vat-rates")
    end
  end

  it "does not replace an existing format with 'placeholder'" do
    entry = create(:entry,
      :content_id => message_data["content_id"],
      :title => "Old VAT rates",
      :format => 'something',
    )

    put_message_on_queue(message_data.merge("format" => "placeholder"))

    eventually do
      entry.reload
      # title updated, but format not updated
      expect(entry.title).to eq("VAT rates")
      expect(entry.format).to eq("something")
    end
  end

  describe "extracting the real format from a format of the form 'placeholder_foo'" do
    it "creates an item with the real format" do
      put_message_on_queue(message_data.merge("format" => "placeholder_answer"))

      eventually do
        expect(Entry.count).to eq(1)
        e = Entry.find_by!(:content_id => message_data["content_id"])
        expect(e).to be
        expect(e.format).to eq("answer")
      end
    end

    it "updates an item with the real format" do
      entry = create(:entry,
        :content_id => message_data["content_id"],
        :title => "Old VAT rates",
        :format => 'old-article',
        :base_path => '/old-vat-rates',
      )

      put_message_on_queue(message_data.merge("format" => "placeholder_answer"))

      eventually do
        entry.reload
        expect(entry.format).to eq("answer")
      end
    end
  end
end
