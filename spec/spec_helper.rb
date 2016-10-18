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

end

RSpec.configure do |c|
  c.include Helpers
end
