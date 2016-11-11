module Eth
  class Key

    attr_reader :private_key, :public_key

    def initialize(priv: nil, openssl: true)
      @private_key = MoneyTree::PrivateKey.new key: priv
      @public_key = MoneyTree::PublicKey.new private_key, compressed: false
      @openssl = openssl
    end

    def private_hex
      private_key.to_hex
    end

    def public_bytes
      public_key.to_bytes
    end

    def public_hex
      public_key.to_hex
    end

    def to_address
      Utils.bin_to_hex(Utils.keccak256(public_bytes[1..-1])[-20..-1])
    end

    def sign(message)
      sign_hash message_hash(message)
    end

    def sign_hash(hash)
      loop do
        signature = (if @openssl then OpenSsl.sign_compact hash, private_hex, public_hex
                                 else Secp256k1.sign_compact hash, private_hex end)
        return signature if valid_s? signature
      end
    end

    def verify_signature(message, signature)
      hash = message_hash(message)
      public_hex == (if @openssl then OpenSsl.recover_compact(hash, signature)
                                 else Secp256k1.recover_compact(hash, signature) end)
    end


    private

    def message_hash(message)
      Utils.keccak256 message
    end

    def valid_s?(signature)
      s_value = Utils.v_r_s_for(signature).last
      s_value <= Ethereum::Base::SECP256K1_N/2 && s_value != 0
    end

  end
end
