# frozen_string_literal: true

%w[bundler fakeredis grape-throttler rack/test rspec/expectations rubygems].each do |file_name|
  require file_name
end

Bundler.setup :default, :test

RSpec.configure do |config|
  config.mock_with :rspec

  config.include Rack::Test::Methods
  config.include RSpec::Matchers
end
