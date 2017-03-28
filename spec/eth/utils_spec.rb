# -*- encoding : ascii-8bit -*-

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

  describe ".base256_to_int" do
    it "properly converts binary to integers" do
      expect(Eth::Utils.base256_to_int("\xff")).to eq(255)
      expect(Eth::Utils.base256_to_int("\x00\x00\xff")).to eq(255)
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

  describe ".keccak256" do
    it "properly hashes using" do
      value = "\xc5\xd2F\x01\x86\xf7#<\x92~}\xb2\xdc\xc7\x03\xc0\xe5\x00\xb6S\xca\x82';{\xfa\xd8\x04]\x85\xa4p"

      expect(value). to eq(Eth::Utils.keccak256(''))
    end
  end

  describe ".keccak256_rlp" do
    it "properly serializes and hashes" do
      value1 = "V\xe8\x1f\x17\x1b\xccU\xa6\xff\x83E\xe6\x92\xc0\xf8n[H\xe0\x1b\x99l\xad\xc0\x01b/\xb5\xe3c\xb4!"
      value2 = "_\xe7\xf9w\xe7\x1d\xba.\xa1\xa6\x8e!\x05{\xee\xbb\x9b\xe2\xac0\xc6A\n\xa3\x8dO?\xbeA\xdc\xff\xd2"
      value3 = "\x1d\xccM\xe8\xde\xc7]z\xab\x85\xb5g\xb6\xcc\xd4\x1a\xd3\x12E\x1b\x94\x8at\x13\xf0\xa1B\xfd@\xd4\x93G"
      value4 = "YZ\xef\x85BA8\x89\x08?\x83\x13\x88\xcfv\x10\x0f\xd8a:\x97\xaf\xb8T\xdb#z#PF89"

      expect(value1).to eq Eth::Utils.keccak256_rlp('')
      expect(value2).to eq Eth::Utils.keccak256_rlp(1)
      expect(value3).to eq Eth::Utils.keccak256_rlp([])
      expect(value4).to eq Eth::Utils.keccak256_rlp([1, [2,3], "4", ["5", [6]]])
    end
  end

  describe ".hex_to_bin" do
    it "raises an error when given invalid hex" do
      expect {
        Eth::Utils.hex_to_bin('xxxx')
      }.to raise_error(TypeError)

      expect {
        Eth::Utils.hex_to_bin("\x00\x00")
      }.to raise_error(TypeError)
    end
  end

  describe ".ripemd160" do
    it "properly hashes with RIPEMD-160" do
      value = "\xc8\x1b\x94\x934 \"\x1az\xc0\x04\xa9\x02B\xd8\xb1\xd3\xe5\x07\r"

      expect(value).to eq Eth::Utils.ripemd160("\x00")
    end
  end

  describe ".format_address" do
    let(:address) { "0x5AAEB6053F3E94C9B9A09F33669435E7EF1BEAED" }
    subject { Eth::Utils.format_address address }

    it "returns checksummed addresses" do
      expect(subject).to eq("0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed")
    end
  end

end
