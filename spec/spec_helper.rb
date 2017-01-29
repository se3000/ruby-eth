$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'eth'
require 'securerandom'

module Helpers

  def bin_to_hex(string)
    string.unpack("H*")[0]
  end

  def hex_to_bin(string)
    [string].pack("H*")
  end

  def read_hex_fixture(name)
    File.read("./spec/fixtures/#{name}.hex").strip
  end

  def configure_defaults
    Eth.configure do |config|
      config.chain_id = nil
      config.tx_data_hex = true
    end
  end

  def configure_chain_id(id)
    Eth.configure do |config|
      config.chain_id = id
    end
  end

  def configure_tx_data_hex(using_hex = true)
    Eth.configure do |config|
      config.tx_data_hex = using_hex
    end
  end

end

RSpec.configure do |config|
  config.include Helpers

  config.before(:example, :chain_id) do |example|
    configure_chain_id example.metadata[:chain_id]
  end

  config.after do
    # always make sure tests are reset to default ID
    # in case they were changed in a test
    configure_defaults
  end
end
