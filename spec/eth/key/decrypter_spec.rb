describe Eth::Key::Decrypter do

  describe ".perform" do
    let(:password) { 'testpassword' }
    let(:key_data) { read_key_fixture password }

    it "recovers the examle key" do
      result = Eth::Key::Decrypter.perform key_data, password
      expect(result).to eq('7a28b5ba57c53603b0b07b56bba752f7784bf506fa95edc395f5cf6c7514fe9d')
    end
  end

end
