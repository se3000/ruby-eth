$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ethereum'

def bin_to_hex(string)
  string.unpack("H*")[0]
end

def hex_to_bin(string)
  [string].pack("H*")
end
