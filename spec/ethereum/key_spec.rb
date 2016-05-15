describe Ethereum::Key, type: :model do
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
end
