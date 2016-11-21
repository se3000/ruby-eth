describe 'EIP 155 and replay protection' do
  let(:key) { Eth::Key.new priv: '4646464646464646464646464646464646464646464646464646464646464646' }

  context "EIP155 example", chain_id: 18 do
    #via https://github.com/ethereum/EIPs/issues/155#issue-183002027

    let(:hex) { 'f86c098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a76400008026a019ae791bb8378a38bb83f5b930fe78a0320cec27d86e5e258c69f0fa9541eb8da02bd8e0c5bde4c0800238ce5a59d2f3ce723f1e84a62cab53d961fe3b019d19fc' }
    let(:expected_signing_data) { 'ec098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a764000080128080' }
    let(:tx) { Eth::Tx.decode hex }

    it "decodes the transaction and recognizes the signer" do
      v_val, r_val, s_val = Eth::Utils.v_r_s_for tx.signature
      signing_data = tx.unsigned_encoded

      expect(v_val).to eq 38
      expect(r_val).to eq 11616088462479929722209511590713166362238170772128436772837473395614974864269
      expect(s_val).to eq 19832642777361886450959973766490059191918327598807281226090984148355472235004
      expect(v_val).to eq(Eth.v_base + 1)

      expect(bin_to_hex signing_data).to eq(expected_signing_data)
      expect(key.verify_signature signing_data, tx.signature).to be true
    end
  end

  context "pre-EIP155 fork" do
    let(:hex) do
      Eth::Tx.new({
        nonce: 9,
        gas_price: (20 * 10**9),
        gas_limit: 21000,
        to: '0x3535353535353535353535353535353535353535',
        value: (10**18),
        data: '',
      }).sign(key).hex
    end
    let(:expected_signing_data) { 'e9098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a764000080' }
    let(:tx) { Eth::Tx.decode hex }

    it "decodes the transaction and recognizes the signer" do
      v_val, r_val, s_val = Eth::Utils.v_r_s_for tx.signature
      signing_data = tx.unsigned_encoded

      expect([Eth.v_base, (Eth.v_base + 1)]).to include v_val

      expect(bin_to_hex signing_data).to eq(expected_signing_data)
      expect(key.verify_signature signing_data, tx.signature).to be true
    end
  end

  context "verifying a post-EIP155 signature with pre-EIP155 configuration" do
    let(:tx) do
      Eth::Tx.new({
        nonce: 9,
        gas_price: (20 * 10**9),
        gas_limit: 21000,
        to: '0x3535353535353535353535353535353535353535',
        value: (10**18),
        data: '',
      })
    end

    it "cannot verify the signature" do
      configure_chain_id 3
      signature = tx.sign(key).signature
      configure_defaults

      expect(key.verify_signature tx.unsigned_encoded, signature).to be false
    end
  end

  context "verifying a pre-EIP155 signature with a post-EIP155 configuration" do
    let(:pre_tx) do
      Eth::Tx.new({
        nonce: 9,
        gas_price: (20 * 10**9),
        gas_limit: 21000,
        to: '0x3535353535353535353535353535353535353535',
        value: (10**18),
        data: '',
      })
    end

    it "can verify the signature" do
      configure_defaults
      pre_tx.sign(key)
      pre_tx_hex = pre_tx.hex
      configure_chain_id 3
      post_tx = Eth::Tx.decode pre_tx_hex

      expect(key.verify_signature post_tx.unsigned_encoded, post_tx.signature).to be true
    end
  end
end
