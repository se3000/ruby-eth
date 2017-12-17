require 'json'
require 'scrypt'

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
    case kdf
    when 'pbkdf2'
      @key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iterations, key_length, digest)
    when 'scrypt'
      # OpenSSL 1.1 inclues OpenSSL::KDF.scrypt, but it is not available usually, otherwise we could do: OpenSSL::KDF.scrypt(password, salt: salt, N: n, r: r, p: p, length: key_length)
      @key = SCrypt::Engine.scrypt(password, salt, n, r, p, key_length)
    else
      raise "Unsupported key derivation function: #{kdf}!"
    end
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

  def kdf
    crypto_data['kdf']
  end

  def key_length
    crypto_data['kdfparams']['dklen'].to_i
  end

  def n
    crypto_data['kdfparams']['n'].to_i
  end

  def r
    crypto_data['kdfparams']['r'].to_i
  end

  def p
    crypto_data['kdfparams']['p'].to_i
  end

  def digest
    OpenSSL::Digest.new digest_name
  end

  def digest_name
    "sha256"
  end
  

end
