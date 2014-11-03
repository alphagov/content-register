require 'rails_helper'

describe "Healthcheck", :type => :request do
  it "returns success" do
    get "/healthcheck"
    expect(response.status).to eq(200)
  end
end
