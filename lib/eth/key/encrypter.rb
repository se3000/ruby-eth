require 'json'

class Eth::Key::Encrypter
  include Eth::Utils

  def self.perform(key, password, options = {})
    new(key, options).perform(password)
  end

  def initialize(key, options = {})
    @key = key
    @options = options
  end

  def perform(password)
    derive_key password
    encrypt

    data.to_json
  end

  def data
    {
      crypto: {
        cipher: cipher_name,
        cipherparams: {
          iv: bin_to_hex(iv),
        },
        ciphertext: bin_to_hex(encrypted_key),
        kdf: "pbkdf2",
        kdfparams: {
          c: iterations,
          dklen: 32,
          prf: prf,
          salt: bin_to_hex(salt),
        },
        mac: bin_to_hex(mac),
      },
      id: id,
      version: 3,
    }.tap do |data|
      data[:address] = address unless options[:skip_address]
    end
  end

  def id
    @id ||= options[:id] || SecureRandom.uuid
  end


  private

  attr_reader :derived_key, :encrypted_key, :key, :options

  def cipher
    @cipher ||= OpenSSL::Cipher.new(cipher_name).tap do |cipher|
      cipher.encrypt
      cipher.iv = iv
      cipher.key = derived_key[0, (key_length/2)]
    end
  end

  def digest
    @digest ||= OpenSSL::Digest.new digest_name
  end

  def derive_key(password)
    @derived_key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iterations, key_length, digest)
  end

  def encrypt
    @encrypted_key = cipher.update(hex_to_bin key) + cipher.final
  end

  def mac
    keccak256(derived_key[(key_length/2), key_length] + encrypted_key)
  end

  def cipher_name
    "aes-128-ctr"
  end

  def digest_name
    "sha256"
  end

  def prf
    "hmac-#{digest_name}"
  end

  def key_length
    32
  end

  def salt_length
    32
  end

  def iv_length
    16
  end

  def iterations
    options[:iterations] || 262_144
  end

  def salt
    if options[:salt]
      hex_to_bin options[:salt]
    else
      SecureRandom.random_bytes(salt_length)
    end
  end

  def iv
    if options[:iv]
      hex_to_bin options[:iv]
    else
      SecureRandom.random_bytes(iv_length)
    end
  end

  def address
    Eth::Key.new(priv: key).address
  end

end
