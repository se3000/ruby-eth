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
      s: s
    })
  end
  let(:tx_fields_42) do
    {
      chain_id: 42,
      nonce: nonce,
      gas_price: gas_price,
      gas_limit: gas_limit,
      to: recipient,
      value: value,
      data: data,
      v: v,
      r: r,
      s: s
    }
  end
  let(:tx_fields_416) do
    {
      chain_id: 416,
      nonce: nonce,
      gas_price: gas_price,
      gas_limit: gas_limit,
      to: recipient,
      value: value,
      data: data,
      v: v,
      r: r,
      s: s
    }
  end
  let(:tx_fields_encoded_416) do
    {
      data: '0xc950f8f0000000000000000000000000762a441605c438742754bb357dd241c8326c25e0000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000028',
      to: '0x69351bffb36f3d1a6fa4374da03562a1935e7047',
      gas_price: 0x3b9aca00,
      value: 0x0,
      nonce: 99,
      chain_id: 416,
      from: '0x22441c383a1e27acbf99663f1861e4936ac86049',
      gas_limit: 71115
    }
  end
  let(:tx_encoded_416) do
    '0xf8cb63843b9aca00830115cb9469351bffb36f3d1a6fa4374da03562a1935e704780b864c950f8f0000000000000000000000000762a441605c438742754bb357dd241c8326c25e0000000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000028820364a03944cee478f84e7186b726858a03b7212281dfd0045df6c22bfb101042a8115ca07676eec5290861869cbd4e029cb8aecb17571dfd2de2499809e462595a956e39'
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
        expect { tx }.to raise_error(Eth::InvalidTransaction, "Gas limit too low")
      end
    end

    context "there are values beyond the unsigned integer max" do
      let(:nonce) { Eth::UINT_MAX + 1 }

      it "raises an InvalidTransaction error" do
        expect { tx }.to raise_error(Eth::InvalidTransaction, "Values way too high!")
      end
    end

    context "when configured to take data as binary" do
      before { configure_tx_data_hex false }
      let(:data) { hex_to_bin SecureRandom.hex }

      it "still propperly sets the data field" do
        expect(tx.data).to eq(data)
      end
    end

    context "when chain_id is not in the parameters" do
      it "uses the default chain ID" do
        cid = Eth.chain_id
        configure_chain_id 42
        tx = Eth::Tx.new({
                           nonce: nonce,
                           gas_price: gas_price,
                           gas_limit: gas_limit,
                           to: recipient,
                           value: value,
                           data: data,
                           v: v,
                           r: r,
                           s: s
                         })
        configure_chain_id cid
        expect(tx.chain_id).to eq 42
      end
    end
  end

  describe ".decode" do
    let(:key) { Eth::Key.new }
    let(:tx1) { tx.sign key }

    it "returns an instance that matches the original encoded one" do
      tx2 = Eth::Tx.decode tx1.encoded
      expect(tx2).to eq(tx1)
    end

    it "also accepts hex" do
      tx2 = Eth::Tx.decode(tx1.hex)
      expect(tx2).to eq(tx1)
    end

    it "decodes Web3.js generated data correctly" do
      tx_416 = Eth::Tx.new tx_fields_encoded_416
      tx2 = Eth::Tx.decode tx_encoded_416
      fields = tx_fields_encoded_416.keys
      tx2_fields = tx2.to_h.select { |k, v| tx_fields_encoded_416.include?(k) }
      tx_416_fields = tx_416.to_h.select { |k, v| tx_fields_encoded_416.include?(k) }
      expect(tx2_fields).to eq(tx_416_fields)
    end

    it "initializes chain_id correctly" do
      tx_416 = Eth::Tx.new tx_fields_encoded_416
      expect(tx_416.chain_id).to eq 416
    end

    it "ignores the default chain ID" do
      configure_chain_id 42
      tx_416 = Eth::Tx.new tx_fields_encoded_416
      expect(tx_416.chain_id).to eq 416
    end
  end

  describe "#sign" do
    let(:v) { nil }
    let(:r) { nil }
    let(:s) { nil }
    let(:key) { Eth::Key.new }

    context "creates a recoverable signature for the transaction" do
      it "with undefined chain ID" do
        tx.sign key
        verified = key.verify_signature tx.unsigned_encoded, tx.ecdsa_signature
        expect(verified).to be_truthy
      end

      it "with small chain ID" do
        tx_42 = Eth::Tx.new(tx_fields_42)
        expect(tx_42.chain_id).to equal(42)
        tx_42.sign key
        verified = key.verify_signature tx_42.unsigned_encoded, tx_42.ecdsa_signature
        expect(verified).to be_truthy
      end

      it "with large chain ID" do
        tx_416 = Eth::Tx.new(tx_fields_416)
        expect(tx_416.chain_id).to equal(416)
        tx_416.sign key
        verified = key.verify_signature tx_416.unsigned_encoded, tx_416.ecdsa_signature
        expect(verified).to be_truthy
      end

      it "with nil chain ID" do
        nil_fields = tx_fields_416
        nil_fields[:chain_id] = nil
        tx_nil = Eth::Tx.new(nil_fields)
        expect(tx_nil.chain_id).to be_nil
        tx_nil.sign key
        verified = key.verify_signature tx_nil.unsigned_encoded, tx_nil.ecdsa_signature
        expect(verified).to be_truthy
      end

      it "after chain ID is modified" do
        tx_42 = Eth::Tx.new(tx_fields_42)
        expect(tx_42.chain_id).to equal(42)
        tx_42.sign key
        verified = key.verify_signature tx_42.unsigned_encoded, tx_42.ecdsa_signature
        expect(verified).to be_truthy

        tx_42.chain_id = 616
        tx_42.sign key
        verified = key.verify_signature tx_42.unsigned_encoded, tx_42.ecdsa_signature
        expect(verified).to be_truthy
      end
    end

    context "generates the same signer for the transaction" do
      it "after chain ID is modified" do
        tx_42 = Eth::Tx.new(tx_fields_42)
        expect(tx_42.chain_id).to equal(42)
        tx_42.sign key
        expect(tx_42.from).to eq(key.address)
        tx_42.chain_id = 616
        expect(tx_42.from).to be_nil
        tx_42.sign key
        expect(tx_42.from).to eq(key.address)
      end
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

    context "from a decoded transaction" do
      it "returns the correct sender" do
        tx2 = Eth::Tx.decode tx_encoded_416
        expect(tx2.from.upcase).to eq(tx_fields_encoded_416[:from].upcase)
      end
    end

    context "when the chain ID is changed" do
      let(:key) { Eth::Key.new priv: '4bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200' }

      it "returns a nil sender if the chain ID did change" do
        tx42 = Eth::Tx.new tx_fields_42
        tx42.sign key
        expect(tx42.from).to eq(key.address)
        tx42.chain_id = 616
        expect(tx42.from).to be_nil
      end

      it "returns a nil sender if the chain ID is nulled" do
        tx42 = Eth::Tx.new tx_fields_42
        tx42.sign key
        expect(tx42.from).to eq(key.address)
        tx42.chain_id = nil
        expect(tx42.from).to be_nil
      end

      it "returns the same sender if the chain ID did not change" do
        tx42 = Eth::Tx.new tx_fields_42
        tx42.sign key
        expect(tx42.from).to eq(key.address)
        tx42.chain_id = tx_fields_42[:chain_id]
        expect(tx42.from).to be_nil
      end
    end
  end

  describe "#hash" do
    let(:txid1) { '0x66734e70ea28eaa28eb1bace4ca87573c48f52cca7590459ad20dc58bae1a819' }
    let(:txid2) { '0x7151f5b0d229c62a5076de4133ba06fffc033e25bf99691c3e0a0a99c5a64538' }
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

  describe "#chain_id" do
    context "when transaction was signed explicitly" do
      let(:key) { Eth::Key.new }
      let(:tx42) { Eth::Tx.new tx_fields_42 }

      it "nulls the signature on a chain ID change" do
        tx42.sign key

        expect(tx42.chain_id).to equal(42)
        expect(tx42.signature).to be_a(Hash)
        expect(tx42.signature).to include(:v, :r, :s)
        tx42.chain_id = 416
        expect(tx42.chain_id).to equal(416)
        expect(tx42.signature).to be_nil
      end

      it "nulls the signature when chain ID is nulled" do
        tx42.sign key

        expect(tx42.chain_id).to equal(42)
        expect(tx42.signature).to be_a(Hash)
        expect(tx42.signature).to include(:v, :r, :s)
        tx42.chain_id = nil
        expect(tx42.chain_id).to be_nil
        expect(tx42.signature).to be_nil
      end

      it "keeps the signature if chain ID does not change" do
        tx42.sign key

        expect(tx42.chain_id).to equal(42)
        expect(tx42.signature).to be_a(Hash)
        expect(tx42.signature).to include(:v, :r, :s)
        osig = {}.merge(tx42.signature)
        tx42.chain_id = 42
        expect(tx42.chain_id).to equal(42)
        expect(tx42.signature).to eq(osig)
      end
    end

    context "when transaction was decoded" do
      let(:tx416) { Eth::Tx.decode tx_encoded_416 }

      it "nulls the signature on a chain ID change" do
        tx416 = Eth::Tx.decode tx_encoded_416
        expect(tx416.chain_id).to equal(416)
        expect(tx416.signature).to be_a(Hash)
        expect(tx416.signature).to include(:v, :r, :s)
        tx416.chain_id = 42
        expect(tx416.chain_id).to equal(42)
        expect(tx416.signature).to be_nil
      end

      it "nulls the signature when chain ID is nulled" do
        tx416 = Eth::Tx.decode tx_encoded_416
        expect(tx416.chain_id).to equal(416)
        expect(tx416.signature).to be_a(Hash)
        expect(tx416.signature).to include(:v, :r, :s)
        tx416.chain_id = nil
        expect(tx416.chain_id).to be_nil
        expect(tx416.signature).to be_nil
      end

      it "keeps the signature if chain ID does not change" do
        tx416 = Eth::Tx.decode tx_encoded_416
        expect(tx416.chain_id).to equal(416)
        expect(tx416.signature).to be_a(Hash)
        expect(tx416.signature).to include(:v, :r, :s)
        osig = {}.merge(tx416.signature)
        tx416.chain_id = 416
        expect(tx416.chain_id).to equal(416)
        expect(tx416.signature).to eq(osig)
      end
    end
  end
end
