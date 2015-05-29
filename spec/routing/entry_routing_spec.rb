require 'rails_helper'

describe "routing of entry requests", :type => :routing do
  let(:content_id) { SecureRandom.uuid }

  context "GET /entries" do
    it "should route to entries#index" do
      expect(get: "/entries").to route_to({
        :controller => 'entries',
        :action => 'index'
      })
    end
  end

  context "PUT /entry" do
    it "should route to entries#update with content_id parameter" do
      expect(put: "/entry/#{content_id}").to route_to({
        :controller => 'entries',
        :action => 'update',
        :id => content_id,
      })
    end
  end
end
