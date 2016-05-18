module Ethereum
  class Key

    attr_reader :private_key, :public_key

    def initialize(priv: nil)
      @private_key = MoneyTree::PrivateKey.new key: priv
      @public_key = MoneyTree::PublicKey.new private_key, compressed: false
    end

    def private_hex
      private_key.to_hex
    end

    def public_hex
      public_key.to_hex
    end

    def sign(message)
      hash = message_hash(message)
      loop do
        signature = OpenSsl.sign_compact hash, private_hex, public_hex
        return signature if valid_s? signature
      end
    end

    def verify_signature(message, signature)
      hash = message_hash(message)
      public_hex == OpenSsl.recover_compact(hash, signature)
    end


    private

    def message_hash(message)
      Digest::SHA256.digest message
    end

    def valid_s?(signature)
      s_value = Utils.v_r_s_for(signature).last
      s_value <= SECP256K1_N/2 && s_value != 0
    end

  end
end
