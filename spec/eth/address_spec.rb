describe Eth::Address do
  describe "#valid?" do
    context "given an address with a valid checksum" do
      let(:addresses) do
        [
          "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
          "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
          "0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB",
          "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
        ]
      end

      it "returns true" do
        addresses.each do |address|
          expect(Eth::Address.new address).to be_valid
        end
      end
    end

    context "given an address with an invalid checksum" do
      let(:addresses) do
        [
          "0x5AAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
          "0xFB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
          "0xDbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB",
          "0xd1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
        ]
      end

      it "returns false" do
        addresses.each do |address|
          expect(Eth::Address.new address).not_to be_valid
        end
      end
    end

    context "given an address with all uppercase letters" do
      let(:addresses) do
        [
          "0x5AAEB6053F3E94C9B9A09F33669435E7EF1BEAED",
          "0xFB6916095CA1DF60BB79CE92CE3EA74C37C5D359",
          "0xDBF03B407C01E7CD3CBEA99509D93F8DDDC8C6FB",
          "0xD1220A0CF47C7B9BE7A2E6BA89F429762E7B9ADB",
          # common EIP55 examples
          "0x52908400098527886E0F7030069857D2E4169EE7",
          "0x8617E340B3D01FA5F11F306F4090FD50E238070D",
        ]
      end

      it "returns true" do
        addresses.each do |address|
          expect(Eth::Address.new address).to be_valid
        end
      end
    end

    context "given an address with all lowercase letters" do
      let(:addresses) do
        [
          "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed",
          "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359",
          "0xdbf03b407c01e7cd3cbea99509d93f8dddc8c6fb",
          "0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb",
          # common EIP55 examples
          "0xde709f2102306220921060314715629080e2fb77",
          "0x27b1fdb04752bbc536007a920d24acb045561c26",
        ]
      end

      it "returns true" do
        addresses.each do |address|
          expect(Eth::Address.new address).to be_valid
        end
      end
    end

    context "given an invalid address" do
      let(:addresses) do
        [
          "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beae",
          "0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359d",
          "0x5AAEB6053F3E94C9B9A09F33669435E7EF1BEAE",
          "0xFB6916095CA1DF60BB79CE92CE3EA74C37C5D359D",
        ]
      end

      it "returns true" do
        addresses.each do |address|
          expect(Eth::Address.new address).not_to be_valid
        end
      end
    end
  end

  describe "#checksummed" do
    let(:addresses) do
      [
        # downcased
        ["0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed", "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"],
        ["0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359", "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"],
        ["0xdbf03b407c01e7cd3cbea99509d93f8dddc8c6fb", "0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB"],
        ["0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb", "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb"],
        # upcased
        ["0x5AAEB6053F3E94C9B9A09F33669435E7EF1BEAED", "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"],
        ["0xFB6916095CA1DF60BB79CE92CE3EA74C37C5D359", "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"],
        ["0xDBF03B407C01E7CD3CBEA99509D93F8DDDC8C6FB", "0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB"],
        ["0xD1220A0CF47C7B9BE7A2E6BA89F429762E7B9ADB", "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb"],
        # checksummed
        ["0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed", "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed"],
        ["0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359", "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"],
        ["0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB", "0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB"],
        ["0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb", "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb"],
      ]
    end

    it "follows EIP55 standard" do
      addresses.each do |plain, checksummed|
        address = Eth::Address.new(plain)
        expect(address.checksummed).to eq checksummed
      end
    end

    context "given an invalid address" do
      let(:bad) { "0x#{SecureRandom.hex(21)[0..40]}" }

      it "raises an error" do
        expect {
          Eth::Address.new(bad).checksummed
        }.to raise_error "Invalid address: #{bad}"
      end
    end
  end
end
