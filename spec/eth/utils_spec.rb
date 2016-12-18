describe Eth::Utils, type: :model do
  describe ".int_to_base256" do
    let(:hex) { '1c18f80381f0ef01e63617fc8eeda646bcef8dea61b34cf0aa079b48ec64e6e55d64d0398818a61bfdcf938e9aa175d16661ffa696629a6abc367a49fad3df90b8' }
    let(:bin) { Eth::Utils.hex_to_bin hex }
    let(:int) { Eth::Utils.base256_to_int bin }

    it "gets the same result back" do
      base256 = Eth::Utils.int_to_base256 int
      expect(base256).to eq(bin)
    end
  end

  describe ".prefix_hex" do
    it "ensures that a hex value has 0x at the beginning" do
      expect(Eth::Utils.prefix_hex('abc')).to eq('0xabc')
      expect(Eth::Utils.prefix_hex('0xabc')).to eq('0xabc')
    end

    it "does not reformat the hex or remove leading zeros" do
      expect(Eth::Utils.prefix_hex('0123')).to eq('0x0123')
    end
  end

  describe ".public_key_to_addres" do
    let(:address) { "0x8abc566c5198bc6993526db697ffe58ce4e2425a" }
    let(:pub) { "0463a1ad6824c03f81ad6c9c224384172c67f6bfd2dbde8c4747a033629b531ae3284db3045e4e40c2b865e22a806ae7dff9264299ea8696321f689d6e134d937e" }

    it "turns a hex public key into a hex address" do
      expect(Eth::Utils.public_key_to_address(pub)).to eq(address)
    end
  end
end
