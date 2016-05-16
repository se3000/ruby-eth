describe Ethereum::Tx, type: :model do
  describe "#initialize" do
    let(:nonce) { rand 1_000_000 }
    let(:gas_price) { 10_000 }
    let(:gas_limit) { 100_000 }
    let(:recipient) { SecureRandom.hex 20 }
    let(:value) { 10**11 }
    let(:data) { SecureRandom.hex }
    let(:v) { 27 }
    let(:r) { rand(1_000_000_000) }
    let(:s) { rand(1_000_000_000) }
    let(:options) { {} }
    let(:tx) { Ethereum::Tx.new(nonce, gas_price, gas_limit, recipient, value, data, v, r, s, options) }

    it "sets the arguments in the order of serializable fields" do
      expect(tx.nonce).to eq(nonce)
      expect(tx.gas_price).to eq(gas_price)
      expect(tx.gas_limit).to eq(gas_limit)
      expect(tx.to).to eq(hex_to_bin recipient)
      expect(tx.value).to eq(value)
      expect(tx.data).to eq(data)
      expect(tx.v).to eq(v)
      expect(tx.r).to eq(r)
      expect(tx.s).to eq(s)
    end

    context "when options are passed in" do
      let(:options) { {value: 42}  }

      it "ignores the extra options" do
        expect(tx.value).to eq(value)
      end
    end

    context "when the gas limit is too low" do
      let(:gas_limit) { 20_000 }

      it "raises an InvalidTransaction error" do
        expect { tx }.to raise_error(Ethereum::InvalidTransaction, "Gas limit too low")
      end
    end

    context "there are values beyond the unsigned integer max" do
      let(:nonce) { Ethereum::UINT_MAX + 1 }

      it "raises an InvalidTransaction error" do
        expect { tx }.to raise_error(Ethereum::InvalidTransaction, "Values way too high!")
      end
    end
  end
end
