#lifted from https://github.com/janx/ruby-ethereum
#TODO: try to extract gem for common behavior

module Ethereum
  class Tx

    include RLP::Sedes::Serializable
    extend Sedes

    set_serializable_fields({
      nonce: big_endian_int,
      gas_price: big_endian_int,
      gas_limit: big_endian_int,
      to: address,
      value: big_endian_int,
      data: binary,
      v: big_endian_int,
      r: big_endian_int,
      s: big_endian_int
    })

    attr_reader :signature

    def self.decode(data)
      data = Utils.hex_to_bin(data) if data.match(/\A\h+\Z/)
      deserialize(RLP.decode data)
    end

    def initialize(*args)
      fields = {v: 0, r: 0, s: 0}.merge parse_field_args(args)
      fields[:to] = Utils.normalize_address(fields[:to])

      serializable_initialize fields

      check_transaction_validity
    end

    def unsigned_encoded
      RLP.encode self, sedes: Tx.exclude([:v, :r, :s])
    end

    def encoded
      RLP.encode self
    end

    def sign(key)
      self.signature = key.sign(unsigned_encoded)
      self.vrs = Utils.v_r_s_for signature

      self
    end

    def to_h
      self.class.serializable_fields.keys.inject({}) do |hash, field|
        hash[field] = send field
        hash
      end
    end


    private

    attr_writer :signature

    def check_transaction_validity
      if [gas_price, gas_limit, value, nonce].max > UINT_MAX
        raise InvalidTransaction, "Values way too high!"
      elsif gas_limit < intrinsic_gas_used
        raise InvalidTransaction, "Gas limit too low"
      end
    end

    def vrs=(vrs)
      self.v = vrs[0]
      self.r = vrs[1]
      self.s = vrs[2]
    end

    def intrinsic_gas_used
      num_zero_bytes = data.count(BYTE_ZERO)
      num_non_zero_bytes = data.size - num_zero_bytes

      GTXCOST + GTXDATAZERO * num_zero_bytes +
        GTXDATANONZERO * num_non_zero_bytes
    end

  end
end
