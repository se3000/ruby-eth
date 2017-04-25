describe Eth::Key::Encrypter do

  describe ".perform" do
    let(:password) { 'testpassword' }
    let(:key) { '7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d' }
    let(:iterations) { 262_144 }
    let(:uuid) { "3198bc9c-6672-5ab3-d995-4942343ae5b6" }
    let(:iv) { '6087dab2f9fdbbfaddc31a909735c1e6' }
    let(:salt) { 'ae3cd4e7013836a3df6bd7241b12db061dbe2c6785853cce422d148a624ce0bd' }
    let(:options) do
      {
        iterations: iterations,
        iv: iv,
        salt: salt,
        id: uuid,
      }
    end

    it "recovers the key" do
      result = Eth::Key::Encrypter.perform key, password, options
      json = JSON.parse(result)

      expect(json['crypto']['cipher']).to eq('aes-128-ctr')
      expect(json['crypto']['cipherparams']['iv']).to eq(iv)
      expect(json['crypto']['ciphertext']).to eq('5318b4d5bcd28de64ee5559e671353e16f075ecae9f99c7a79a38af5f869aa46')
      expect(json['crypto']['kdf']).to eq('pbkdf2')
      expect(json['crypto']['kdfparams']['c']).to eq(iterations)
      expect(json['crypto']['kdfparams']['dklen']).to eq(32)
      expect(json['crypto']['kdfparams']['prf']).to eq("hmac-sha256")
      expect(json['crypto']['kdfparams']['salt']).to eq(salt)
      expect(json['crypto']['mac']).to eq('517ead924a9d0dc3124507e3393d175ce3ff7c1e96529c6c555ce9e51205e9b2')
      expect(json['id']).to eq(uuid)
      expect(json['version']).to eq(3)
    end
  end

end
