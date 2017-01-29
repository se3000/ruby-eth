describe Eth do

  describe ".configure" do
    it "defaults to nil" do
      expect(Eth.chain_id).to be_nil
    end

    it "allows you to configure the chain ID" do
      expect {
        Eth.configure { |config| config.chain_id = 42 }
      }.to change {
        Eth.chain_id
      }.from(nil).to(42)
    end
  end

  describe "#v_base" do
    it "is set to 27 by default" do
      expect(Eth.v_base).to eq(27)
    end

    it "calculates it off of the chain ID" do
      expect {
        Eth.configure { |config| config.chain_id = 42 }
      }.to change {
        Eth.v_base
      }.from(27).to(119)
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

  describe "#prevent_replays?" do
    subject { Eth.prevent_replays? }

    context "when configured to the defaults" do
      before { configure_defaults }
      it { is_expected.to be false }
    end

    context "when configured to a new chain" do
      before { configure_chain_id 42 }
      it { is_expected.to be true }
    end

    context "when configured to the replayable chain" do
      before { configure_chain_id 13 }
      it { is_expected.to be true }
    end
  end
end
