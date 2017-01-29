describe Eth::Tx, type: :model do
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
  let(:tx) do
    Eth::Tx.new({
      nonce: nonce,
      gas_price: gas_price,
      gas_limit: gas_limit,
      to: recipient,
      value: value,
      data: data,
      v: v,
      r: r,
      s: s,
    })
  end

  describe "#initialize" do
    it "sets the arguments in the order of serializable fields" do
      expect(tx.nonce).to eq(nonce)
      expect(tx.gas_price).to eq(gas_price)
      expect(tx.gas_limit).to eq(gas_limit)
      expect(tx.to).to eq(hex_to_bin recipient)
      expect(tx.value).to eq(value)
      expect(tx.data).to eq("0x#{data}")
      expect(tx.v).to eq(v)
      expect(tx.r).to eq(r)
      expect(tx.s).to eq(s)
    end

    context "when the gas limit is too low" do
      let(:gas_limit) { 20_000 }

      it "raises an InvalidTransaction error" do
        expect { tx }.to raise_error(Ethereum::Base::InvalidTransaction, "Gas limit too low")
      end
    end

    context "there are values beyond the unsigned integer max" do
      let(:nonce) { Ethereum::Base::UINT_MAX + 1 }

      it "raises an InvalidTransaction error" do
        expect { tx }.to raise_error(Ethereum::Base::InvalidTransaction, "Values way too high!")
      end
    end

    context "when configured to take data as binary" do
      before { configure_tx_data_hex false }
      let(:data) { hex_to_bin SecureRandom.hex }

      it "still propperly sets the data field" do
        expect(tx.data).to eq(data)
      end
    end
  end

  describe ".decode" do
    let(:key) { Eth::Key.new }
    let(:tx1) { tx.sign key }

    it "returns an instance that matches the original enocded one" do
      tx2 = Eth::Tx.decode tx1.encoded
      expect(tx2).to eq(tx1)
    end

    it "also accepts hex" do
      tx2 = Eth::Tx.decode(tx1.hex)
      expect(tx2).to eq(tx1)
    end
  end

  describe "#sign" do
    let(:v) { nil }
    let(:r) { nil }
    let(:s) { nil }
    let(:key) { Eth::Key.new }

    it "creates a recoverable signature for the transaction" do
      tx.sign key
      verified = key.verify_signature tx.unsigned_encoded, tx.signature
      expect(verified).to be_truthy
    end
  end

  describe "#to_h" do
    let(:key) { Eth::Key.new }

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

    it "does not set the binary data field" do
      hash = tx.to_h
      expect(hash[:data_bin]).to be_nil
    end

    it "can be converted back into a transaction" do
      tx2 = Eth::Tx.new(tx.to_h)
      expect(tx2.data).to eq tx.data
      expect(tx2).to eq tx
    end
  end

  describe "#hex" do
    let(:key) { Eth::Key.new }

    it "creates a hex representation" do
      tx = Eth::Tx.new({
        data: 'abcdef',
        gas_limit: 3_141_592,
        gas_price: 20_000_000_000,
        nonce: 0,
        to: key.address,
        value: 1_000_000_000_000,
      })

      expect(tx.hex).not_to be_nil
    end
  end

  describe "#from" do
    let(:key) { Eth::Key.new }
    subject { tx.from }

    context "when the signature is present" do
      before do
        tx.sign key
      end

      it { is_expected.to eq(key.address) }
    end

    context "when the signature does NOT match" do
      before do
        tx.sign key
        tx.signature = nil
        tx.r = tx.r + 1
      end

      it { is_expected.not_to eq(key.address) }
    end

    context "when the signature is NOT present" do
      let(:v) { nil }
      let(:r) { nil }
      let(:s) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe "#hash" do
    let(:txid1) { '66734e70ea28eaa28eb1bace4ca87573c48f52cca7590459ad20dc58bae1a819' }
    let(:txid2) { '7151f5b0d229c62a5076de4133ba06fffc033e25bf99691c3e0a0a99c5a64538' }
    let(:txids) { [txid1, txid2] }

    it "hashes the serialized full transaction" do
      txids.each do |txid|
        tx = Eth::Tx.decode read_hex_fixture(txid)
        expect(tx.hash).to eq(txid)
        expect(tx.id).to eq(txid)
      end
    end
  end

  describe "#data_hex" do
    it "converts the hex to binary and persists it" do
      hex = '0123456789abcdef'
      binary = Eth::Utils.hex_to_bin hex

      expect {
        tx.data_hex = hex
      }.to change {
        tx.data_bin
      }.to(binary).and change {
        tx.data_hex
      }.to("0x#{hex}")
    end
  end

  describe "#data_bin" do
    it "returns the data in a binary format" do
      hex = '0123456789abcdef'
      binary = Eth::Utils.hex_to_bin hex

      expect {
        tx.data_bin = binary
      }.to change {
        tx.data_bin
      }.to(binary).and change {
        tx.data
      }.to("0x#{hex}")
    end
  end

  describe "#data" do
    after { configure_tx_data_hex }

    let(:hex) { '0123456789abcdef' }
    let(:binary) { Eth::Utils.hex_to_bin hex }

    context "when configured to use hex" do
      before { configure_tx_data_hex true }

      it "accepts hex" do
        expect {
          tx.data = hex
        }.to change {
          tx.data_bin
        }.to(binary).and change {
          tx.data_hex
        }.to("0x#{hex}")
      end
    end

    context "when configured to use binary" do
      before { configure_tx_data_hex false }

      it "converts the hex to binary and persists it" do
        expect {
          tx.data = binary
        }.to change {
          tx.data_bin
        }.to(binary).and change {
          tx.data_hex
        }.to("0x#{hex}")
      end
    end
  end
end
