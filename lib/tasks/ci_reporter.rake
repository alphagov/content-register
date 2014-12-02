if Rails.env.development? or Rails.env.test?
  require 'ci/reporter/rake/rspec'

  # Disable output capture because it interferes with childprocess.
  # https://github.com/ci-reporter/ci_reporter#environment-variables
  ENV["CI_CAPTURE"] = "off"
end
