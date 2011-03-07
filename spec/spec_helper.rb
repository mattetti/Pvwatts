$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'pvwatts'
require 'savon'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# Set this constant to run the tests
PVWATTS_SPEC_KEY = nil
raise "You first need to set the PVWATTS_SPEC_KEY constant in spec_helper.rb" if PVWATTS_SPEC_KEY.nil?

RSpec.configure do |config|
  
end
