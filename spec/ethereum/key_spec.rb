describe Ethereum::Key, type: :model do
  let(:priv) { nil }
  subject(:key) { Ethereum::Key.new priv: priv }

  describe "#initialize" do
    it "returns a key with a new private key" do
      key1 = Ethereum::Key.new
      key2 = Ethereum::Key.new

      expect(key1.private_hex).not_to eq(key2.private_hex)
      expect(key1.public_hex).not_to eq(key2.public_hex)
    end

    it "regenerates an old private key" do
      key1 = Ethereum::Key.new
      key2 = Ethereum::Key.new priv: key1.private_hex

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
        s_value = Ethereum::Utils.v_r_s_for(signature).last
        expect(s_value).to be < (Ethereum::SECP256K1_N/2)
      end
    end
  end

  describe "#verify_signature" do
    let(:priv) { '5a37533acfa3ff9386aed01e16c0e7a79038ce05cc383e290d360b8ce9cd6fdf' }
    let(:message) { "Hi Mom!" }

    context "when the signature matches the public key" do
      let(:signature) { hex_to_bin "1b9ab60357da1d9f4dbd52463142885a7f1f7f79a1119af623a7d8444a2b8eaa6aab759afdf49400fe08ab01eedee20b900753ca5a04e48ca49f491e067ca17bb5" }

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
end
