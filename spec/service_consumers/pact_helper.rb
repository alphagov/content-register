require 'pact/provider/rspec'
Pact.configure do | config |
  config.reports_dir = "spec/reports/pacts"
end

Pact.service_provider "Content register" do
  honours_pact_with 'GDS API Adapters' do
    pact_uri '../gds-api-adapters/spec/pacts/gds_api_adapters-content_register.json'
  end
end

Pact.provider_states_for "GDS API Adapters" do
  provider_state "an empty content register" do
    set_up do
      DatabaseCleaner.clean_with :truncation
    end
  end

  provider_state "an entry exists at /entry/16894762-dd99-40ca-9cbf-eb18a1567c0a" do
    set_up do
      DatabaseCleaner.clean_with :truncation
      FactoryGirl.create(:entry, content_id: "16894762-dd99-40ca-9cbf-eb18a1567c0a")
    end
  end
end
