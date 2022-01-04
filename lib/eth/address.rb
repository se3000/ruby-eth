module Eth
  class Address
    def initialize(address)
      @address = Utils.prefix_hex(address)
    end

    def valid?
      if !matches_any_format?
        false
      elsif not_checksummed?
        true
      else
        checksum_matches?
      end
    end

    def checksummed
      raise "Invalid address: #{address}" unless matches_any_format?

      cased = unprefixed.chars.zip(checksum.chars).map do |char, check|
        check.match(/[0-7]/) ? char.downcase : char.upcase
      end

      Utils.prefix_hex(cased.join)
    end

    private

    attr_reader :address

    def checksum_matches?
      address == checksummed
    end

    def not_checksummed?
      all_uppercase? || all_lowercase?
    end

    def all_uppercase?
      address.match(/(?:0[xX])[A-F0-9]{40}/)
    end

    def all_lowercase?
      address.match(/(?:0[xX])[a-f0-9]{40}/)
    end

    def matches_any_format?
      address.match(/\A(?:0[xX])[a-fA-F0-9]{40}\z/)
    end

    def checksum
      Utils.bin_to_hex(Utils.keccak256 unprefixed.downcase)
    end

    def unprefixed
      Utils.remove_hex_prefix address
    end
  end
end
