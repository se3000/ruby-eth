describe Ethereum::Tx, type: :model do
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

  describe "#initialize" do
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

  describe ".decode" do
    let(:key) { Ethereum::Key.new }
    let(:tx1) { tx.sign key }

    it "returns an instance that matches the original enocded one" do
      tx2 = Ethereum::Tx.decode tx1.encoded
      expect(tx2).to eq(tx1)
    end

    it "also accepts hex" do
      tx2 = Ethereum::Tx.decode(Ethereum::Utils.bin_to_hex tx1.encoded)
      expect(tx2).to eq(tx1)
    end
  end

  describe "#sign" do
    let(:v) { nil }
    let(:r) { nil }
    let(:s) { nil }
    let(:key) { Ethereum::Key.new }

    it "creates a recoverable signature for the transaction" do
      tx.sign key
      verified = key.verify_signature tx.unsigned_encoded, tx.signature
      expect(verified).to be_truthy
    end
  end

  describe "#to_h" do
    let(:key) { Ethereum::Key.new }

    before { tx.sign key }

    it "returns all the same values" do
      hash = tx.to_h

      expect(hash[:nonce]).to eq(tx.nonce)
      expect(hash[:gas_price]).to eq(tx.gas_price)
      expect(hash[:gas_limit]).to eq(tx.gas_limit)
      expect(hash[:to]).to eq(tx.to)
      expect(hash[:data]).to eq(tx.data)
      expect(hash[:v]).to eq(tx.v)
      expect(hash[:r]).to eq(tx.r)
      expect(hash[:s]).to eq(tx.s)
    end

    it "can be converted back into a transaction" do
      tx2 = Ethereum::Tx.new(tx.to_h)
      expect(tx2).to eq tx
    end
  end

  describe "#from" do
    let(:key) { Ethereum::Key.new }
    subject { tx.from }

    context "when the signature is present" do
      before do
        tx.sign key
      end

      it { is_expected.to eq(key.public_hex) }
    end

    context "when the signature does NOT match" do
      before do
        tx.sign key
        tx.signature = nil
        tx.r = tx.r + 1
      end

      it { is_expected.not_to eq(key.public_hex) }
    end

    context "when the signature is NOT present" do
      let(:v) { nil }
      let(:r) { nil }
      let(:s) { nil }

      it { is_expected.to be_nil }
    end
  end
end
