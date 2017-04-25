require 'json'

class Eth::Key::Decrypter
  include Eth::Utils

  def self.perform(data, password)
    new(data, password).perform
  end

  def initialize(data, password)
    @data = JSON.parse(data)
    @password = password
  end

  def perform
    derive_key password
    check_macs
    bin_to_hex decrypted_data
  end


  private

  attr_reader :data, :key, :password

  def derive_key(password)
    @key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iterations, key_length, digest)
  end

  def check_macs
    mac1 = keccak256(key[(key_length/2), key_length] + ciphertext)
    mac2 = hex_to_bin crypto_data['mac']

    if mac1 != mac2
      raise "Message Authentications Codes do not match!"
    end
  end

  def decrypted_data
    @decrypted_data ||= cipher.update(ciphertext) + cipher.final
  end

  def crypto_data
    @crypto_data ||= data['crypto'] || data['Crypto']
  end

  def ciphertext
    hex_to_bin crypto_data['ciphertext']
  end

  def cipher_name
    "aes-128-ctr"
  end

  def cipher
    @cipher ||= OpenSSL::Cipher.new(cipher_name).tap do |cipher|
      cipher.decrypt
      cipher.key = key[0, (key_length/2)]
      cipher.iv = iv
    end
  end

  def iv
    hex_to_bin crypto_data['cipherparams']['iv']
  end

  def salt
    hex_to_bin crypto_data['kdfparams']['salt']
  end

  def iterations
    crypto_data['kdfparams']['c'].to_i
  end

  def key_length
    32
  end

  def digest
    OpenSSL::Digest.new digest_name
  end

  def digest_name
    "sha256"
  end

end
