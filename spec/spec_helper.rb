# frozen_string_literal: true

require 'bundler/setup'
require 'fakeredis'

require 'grape-throttler'

spec_path = Pathname.new(File.expand_path('../spec', File.dirname(__FILE__)))

Dir.each_child(spec_path.join('support/config')) do |f|
  load(spec_path.join("support/config/#{f}"))
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
