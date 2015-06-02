#!/bin/bash -x
set -e

export RAILS_ENV=test

git clean -fdx
bundle install --path "${HOME}/bundles/${JOB_NAME}" --deployment
bundle exec rake db:drop db:create db:schema:load
bundle exec rake ci:setup:rspec default
bundle exec rake pact:verify:at[https://pactcontract:"${PACT_CI_API_KEY}"@ci-new.alphagov.co.uk/job/govuk_gds_api_adapters_contract_tests/lastSuccessfulBuild/artifact/spec/pacts/gds_api_adapters-content_register.json]
