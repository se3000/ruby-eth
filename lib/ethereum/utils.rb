module Ethereum
  module Utils

    extend self

    def normalize_address(address)
      if address.nil? || address == ''
        ''
      elsif address.size == 40
        hex_to_bin address
      elsif address.size == 42 && address[0..1] == '0x'
        hex_to_bin address[2..-1]
      else
        address
      end
    end

    def bin_to_hex(string)
      string.unpack("H*")[0]
    end

    def hex_to_bin(string)
      [string].pack("H*")
    end

    def base256_to_int(string)
      string.bytes.inject do |result, byte|
        result *= 256
        result + byte
      end
    end

    def v_r_s_for(signature)
      [
        signature[0].bytes[0],
        Utils.base256_to_int(signature[1..32]),
        Utils.base256_to_int(signature[33..65]),
      ]
    end

  end
end
