module Eth
  class Address

    def initialize(address)
      @address = address
    end

    def valid?
      if not_checksummed?
        true
      else
        checksum_matches?
      end
    end


    private

    attr_reader :address

    def checksum_matches?
      unprefixed.chars.zip(checksum.chars).each do |char, check|
        next unless char.match(/[a-fA-F]/)

        if check.match(/[0-7]/) && char.match(/[A-F]/)
          break false
        elsif check.match(/[89a-f]/i) && char.match(/[a-f]/)
          break false
        else
          true
        end
      end
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

    def checksum
      Utils.bin_to_hex(Utils.keccak256 unprefixed.downcase)
    end

    def unprefixed
      Utils.remove_hex_prefix address
    end

  end
end
