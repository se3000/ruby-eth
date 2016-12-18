module Eth
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

    attr_writer :signature

    def self.decode(data)
      data = Utils.hex_to_bin(data) if data.match(/\A\h+\Z/)
      deserialize(RLP.decode data)
    end

    def initialize(params)
      fields = {v: 0, r: 0, s: 0}.merge params
      fields[:to] = Utils.normalize_address(fields[:to])

      serializable_initialize fields

      check_transaction_validity
    end

    def unsigned_encoded
      RLP.encode(unsigned, sedes: sedes)
    end

    def signing_data
      Utils.bin_to_hex unsigned_encoded
    end

    def encoded
      RLP.encode self
    end

    def hex
      Utils.bin_to_hex encoded
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

    def from
      return @from if @from
      @from ||= OpenSsl.recover_compact(signature_hash, signature) if signature
    end

    def signature
      return @signature if @signature
      self.signature = [v, r, s].map do |integer|
        Utils.int_to_base256 integer
      end.join if [v, r, s].all?
    end

    def hash
      Utils.bin_to_hex Utils.keccak256_rlp(self)
    end

    def data_hex=(string)
      self.data = Utils.hex_to_bin(string)
    end

    def data_hex
      Utils.bin_to_hex(data) unless data.nil?
    end


    private

    def check_transaction_validity
      if [gas_price, gas_limit, value, nonce].max > Ethereum::Base::UINT_MAX
        raise Ethereum::Base::InvalidTransaction, "Values way too high!"
      elsif gas_limit < intrinsic_gas_used
        raise Ethereum::Base::InvalidTransaction, "Gas limit too low"
      end
    end

    def vrs=(vrs)
      self.v = vrs[0]
      self.r = vrs[1]
      self.s = vrs[2]
    end

    def intrinsic_gas_used
      num_zero_bytes = data.count(Ethereum::Base::BYTE_ZERO)
      num_non_zero_bytes = data.size - num_zero_bytes

      Ethereum::Base::GTXCOST +
        Ethereum::Base::GTXDATAZERO * num_zero_bytes +
        Ethereum::Base::GTXDATANONZERO * num_non_zero_bytes
    end

    def signature_hash
      Utils.keccak256 unsigned_encoded
    end

    def unsigned
      Tx.new to_h.merge(v: Eth.chain_id, r: 0, s: 0)
    end

    def sedes
      if Eth.prevent_replays? && !(Eth.replayable_v? v)
        self.class
      else
        UnsignedTx
      end
    end

  end

  UnsignedTx = Tx.exclude([:v, :r, :s])
end
