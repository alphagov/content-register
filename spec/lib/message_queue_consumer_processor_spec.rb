require 'rails_helper'

require 'message_queue_consumer'

describe MessageQueueConsumer::Processor do
  let(:base_message_data) {
    {
      "base_path" => "/vat-rates",
      "content_id" => SecureRandom.uuid,
      "title" => "VAT rates",
      "description" => "Current VAT rates",
      "format" => "answer",
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
  let(:message) { instance_double("RabbitmqConsumer::Message", :body_data => message_data, :ack => nil) }

  context "for an item with a content Id" do
    let(:message_data) { base_message_data }

    it "creates an entry" do
      expect {
        subject.call(message)
      }.to change(Entry, :count).by(1)

      entry = Entry.find_by(:content_id => message_data["content_id"])
      expect(entry).to be
      expect(entry.title).to eq("VAT rates")
      expect(entry.format).to eq("answer")
      expect(entry.base_path).to eq("/vat-rates")
    end

    it "updates an existing entry" do
      entry = create(:entry,
        :content_id => message_data["content_id"],
        :title => "Old VAT rates",
        :format => 'old-article',
        :base_path => '/old-vat-rates',
      )

      subject.call(message)

      entry.reload
      expect(entry.title).to eq("VAT rates")
      expect(entry.format).to eq("answer")
      expect(entry.base_path).to eq("/vat-rates")
    end

    it "acks the message" do
      expect(message).to receive(:ack)

      subject.call(message)
    end

    describe "placeholder format special case" do
      let(:message_data) { base_message_data.merge("format" => "placeholder") }

      it "creates an entry with a format of 'placeholder'" do
        expect {
          subject.call(message)
        }.to change(Entry, :count).by(1)

        entry = Entry.find_by(:content_id => message_data["content_id"])
        expect(entry).to be
        expect(entry.format).to eq("placeholder")
      end

      it "does not replace an existing format with 'placeholder'" do
        entry = create(:entry,
          :content_id => message_data["content_id"],
          :title => "Old VAT rates",
          :format => 'article',
        )

        subject.call(message)

        entry.reload
        expect(entry.format).to eq("article")
      end
    end

    describe "placeholder format prefix special case" do
      let(:message_data) { base_message_data.merge("format" => "placeholder_answer") }

      it "creates an entry with a format of 'answer'" do
        expect {
          subject.call(message)
        }.to change(Entry, :count).by(1)

        entry = Entry.find_by(:content_id => message_data["content_id"])
        expect(entry).to be
        expect(entry.format).to eq("answer")
      end

      it "replaces an existing format with 'answer'" do
        entry = create(:entry,
          :content_id => message_data["content_id"],
          :title => "Old VAT rates",
          :format => 'article',
        )

        subject.call(message)

        entry.reload
        expect(entry.format).to eq("answer")
      end
    end
  end

  context "for an item without a content Id" do
    let(:message_data) {
      base_message_data.tap {|h| h.delete("content_id") }
    }

    it "does not create an Entry" do
      expect {
        subject.call(message)
      }.not_to change(Entry, :count)
    end

    it "acks the message" do
      expect(message).to receive(:ack)
      subject.call(message)
    end
  end
end
