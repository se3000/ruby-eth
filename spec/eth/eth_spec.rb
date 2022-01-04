describe Eth do
  describe ".configure" do
  end

  describe "#v_base" do
    it "is set to 27 by default" do
      expect(Eth.v_base).to eq(27)
    end
  end

  describe "#replayable_v?" do
    it "returns true for anything other than 27 and 28" do
      expect(Eth.replayable_v? 0).to be false
      expect(Eth.replayable_v? nil).to be false
      expect(Eth.replayable_v? 26).to be false
      expect(Eth.replayable_v? 27).to be true
      expect(Eth.replayable_v? 28).to be true
      expect(Eth.replayable_v? 28.1).to be false
      expect(Eth.replayable_v? 29).to be false
      expect(Eth.replayable_v? Float::INFINITY).to be false
    end
  end

  describe "#chain_id_from_signature" do
    it "converts v to the correct chain ID" do
      expect(Eth.chain_id_from_signature({ v: 27, r: 0, s: 0 })).to be_nil
      expect(Eth.chain_id_from_signature({ v: 28, r: 0, s: 0 })).to be_nil
      expect(Eth.chain_id_from_signature({ v: 29, r: 0, s: 0 })).to be_nil
      expect(Eth.chain_id_from_signature({ v: 30, r: 0, s: 0 })).to be_nil
      expect(Eth.chain_id_from_signature({ v: 36, r: 0, s: 0 })).to be_nil
      expect(Eth.chain_id_from_signature({ v: 37, r: 0, s: 0 })).to eq(1)
      expect(Eth.chain_id_from_signature({ v: 38, r: 0, s: 0 })).to eq(1)
      expect(Eth.chain_id_from_signature({ v: 119, r: 0, s: 0 })).to eq(42)
      expect(Eth.chain_id_from_signature({ v: 120, r: 0, s: 0 })).to eq(42)
      expect(Eth.chain_id_from_signature({ v: 867, r: 0, s: 0 })).to eq(416)
      expect(Eth.chain_id_from_signature({ v: 868, r: 0, s: 0 })).to eq(416)
    end
  end
end
