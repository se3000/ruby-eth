# Eth [![Travis-CI](https://travis-ci.org/se3000/ruby-eth.svg?branch=master)](https://travis-ci.org/se3000/ruby-eth) [![Code Climate](https://codeclimate.com/github/se3000/ruby-eth/badges/gpa.svg)](https://codeclimate.com/github/se3000/ruby-eth) [![Gitter](https://badges.gitter.im/ruby-eth/Lobby.svg)](https://gitter.im/ruby-eth/Lobby)

[![Join the chat at https://gitter.im/ruby-eth/Lobby](https://badges.gitter.im/ruby-eth/Lobby.svg)](https://gitter.im/ruby-eth/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A simple library to build and sign Ethereum transactions. Allows separataion of key and node management. Sign transactions and handle keys anywhere you can run ruby, boradcast transactions through any node.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eth

## Usage

### Keys
Create a new public/private key and get its address:
```ruby
key = Eth::Key.new
key.private_hex
key.public_hex
key.address # EIP55 checksummed address
```
Import an existing key:
```ruby
old_key = Eth::Key.new priv: private_key
```
Or decrypt an [encrypted key](https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition):
```ruby
decrypted_key = Eth::Key.decrypt File.read('./some/path.json'), 'p455w0rD'
```
You can also encrypt your keys for use with other ethereum libraries:
```ruby
encrypted_key_info = Eth::Key.encrypt key, 'p455w0rD'
```

### Transactions

Build a transaction from scratch:
```ruby
tx = Eth::Tx.new({
  data: hex_data,
  gas_limit: 21_000,
  gas_price: 3_141_592,
  nonce: 1,
  to: key2.address,
  value: 1_000_000_000_000,
})
```
Or decode an encoded raw transaction:
```ruby
tx = Eth::Tx.decode hex
```

Then sign the transaction:
```ruby
tx.sign key
```
Get the raw transaction with `tx.hex`, and broadcast it through any Ethereum node. Or, just get the TXID with `tx.hash`.

### Utils

Validate an [EIP55](https://github.com/ethereum/EIPs/issues/55) checksummed address:
```ruby
Eth::Utils.valid_address? address
```

Or add a checksum to an existing address:
```ruby
Eth::Utils.format_address "0x4bc787699093f11316e819b5692be04a712c4e69" # => "0x4bc787699093f11316e819B5692be04A712C4E69"
```

### Configure
In order to prevent replay attacks, you must specify which Ethereum chain your transactions are created for. See [EIP 155](https://github.com/ethereum/EIPs/issues/155) for more detail.
```ruby
Eth.configure do |config|
  config.chain_id = 1 # nil by default, meaning valid on any chain
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/se3000/ethereum-tx. Tests are encouraged.

### Tests

First install the [Ethereum common tests](https://github.com/ethereum/tests):
```shell
git submodule update --init
```

Then run the associated tests:
```shell
rspec
```


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODO
- Better test suite.
- Expose API for HD keys.
- Support signing with [libsecp256k1](https://github.com/bitcoin-core/secp256k1).
