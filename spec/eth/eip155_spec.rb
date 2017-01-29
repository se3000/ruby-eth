describe 'EIP 155 and replay protection' do
  let(:key) { Eth::Key.new priv: '4646464646464646464646464646464646464646464646464646464646464646' }

  context "EIP155 example", chain_id: 1 do
    #via https://github.com/ethereum/EIPs/issues/155#issue-183002027

    let(:hex) { '0xf86c098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a76400008025a006f3c7fb391722beb8ae599a899fe6fd6f6eae4b0f3df4bbc54bc3c673aa92cda0423bb70e7f851514a73a14cee940ec0acab1bab6fb274fa7b922adbdcbf08611' }
    let(:expected_signing_data) { 'ec098504a817c800825208943535353535353535353535353535353535353535880de0b6b3a764000080018080' }
    let(:tx) { Eth::Tx.decode hex }
    let(:signing_data) { tx.unsigned_encoded }

    it "decodes the transaction and recognizes the signer" do
      v_val, r_val, s_val = Eth::Utils.v_r_s_for tx.signature

      expect(v_val).to eq 37
      expect(r_val).to eq 3144601148722688608716531623347812328676993065715946531989621665587339629261
      expect(s_val).to eq 29958155393767630265145914935642492209353907522463775796041782419660953650705

      expect(bin_to_hex signing_data).to eq(expected_signing_data)
      expect(key.verify_signature signing_data, tx.signature).to be true
      expect(key.address).to eq(tx.from)
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
