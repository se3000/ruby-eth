describe Ethereum::Tx::Key, type: :model do
  let(:priv) { nil }
  subject(:key) { Ethereum::Tx::Key.new priv: priv }

  describe "#initialize" do
    it "returns a key with a new private key" do
      key1 = Ethereum::Tx::Key.new
      key2 = Ethereum::Tx::Key.new

      expect(key1.private_hex).not_to eq(key2.private_hex)
      expect(key1.public_hex).not_to eq(key2.public_hex)
    end

    it "regenerates an old private key" do
      key1 = Ethereum::Tx::Key.new
      key2 = Ethereum::Tx::Key.new priv: key1.private_hex

      expect(key1.private_hex).to eq(key2.private_hex)
      expect(key1.public_hex).to eq(key2.public_hex)
    end
  end

  describe "#sign" do
    let(:message) { "Hi Mom!" }

    it "signs a message so that the public key is recoverable" do
      10.times do
        signature = key.sign message
        expect(key.verify_signature message, signature).to be_truthy
        s_value = Ethereum::Tx::Utils.v_r_s_for(signature).last
        expect(s_value).to be < (Ethereum::Tx::SECP256K1_N/2)
      end
    end
  end

  describe "#verify_signature" do
    let(:priv) { '5a37533acfa3ff9386aed01e16c0e7a79038ce05cc383e290d360b8ce9cd6fdf' }
    let(:message) { "Hi Mom!" }

    context "when the signature matches the public key" do
      let(:signature) { hex_to_bin "1ce2f13b4123a23a4a280ac4adcba1ffa3f3848f494dc1de440af43f677e0e01260fb4667ed117d555659b249702c8215162b3f0ee09628813a4ef83616f99f180" }

      it "signs a message so that the public key is recoverable" do
        expect(key.verify_signature message, signature).to be_truthy
      end
    end

    context "when the signature matches another public key" do
      let(:other_priv) { 'fd7f87d1f8c6cdfeb36caa491864519e89b405850c9e2e070839e74966d810cf' }
      let(:signature) { hex_to_bin "1b21a66b55af07a2b0981e3a0ba1768382c5bdbed3d16bcc58a8011425b3bbc090f881cc13d16792af55438637fbe9a2a81d85d6bb18b87b6c08aa9c20ce1341f4" }

      it "signs a message so that the public key is recoverable" do
        expect(key.verify_signature message, signature).to be_falsy
      end
    end

    context "when the signature does not match any public key" do
      let(:signature) { hex_to_bin "1b21a66b" }

      it "signs a message so that the public key is recoverable" do
        expect(key.verify_signature message, signature).to be_falsy
      end
    end
  end

  describe "#to_address" do
    subject { key.to_address }
    let(:priv) { 'c3a4349f6e57cfd2cbba275e3b3d15a2e4cf00c89e067f6e05bfee25208f9cbb' }
    it { is_expected.to eq('759b427456623a33030bbc2195439c22a8a51d25') }
  end
end
