require 'money-tree'

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

  end
end
