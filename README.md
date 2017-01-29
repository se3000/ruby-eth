# Eth [![Travis-CI](https://travis-ci.org/se3000/ruby-eth.svg?branch=master)](https://travis-ci.org/se3000/ruby-eth) [![Code Climate](https://codeclimate.com/github/se3000/ruby-eth/badges/gpa.svg)](https://codeclimate.com/github/se3000/ruby-eth) [![Gitter](https://badges.gitter.im/ruby-eth/Lobby.svg)](https://gitter.im/ruby-eth/Lobby)

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
Create a new key:
```ruby
key = Eth::Key.new
```
Or import and existing one:
```ruby
old_key = Eth::Key.new priv: private_key
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

### Configure
In order to prevent replay attacks, you must specify which Ethereum chain your transactions are created for. See [EIP 155](https://github.com/ethereum/EIPs/issues/155) for more detail.
```ruby
Eth.configure do |config|
  config.chain_id = 1 # nil by default, meaning valid on any chain
end
```

Then sign the transaction:
```ruby
tx.sign key
```
Get the raw transaction with `tx.hex`, and broadcast it through any Ethereum node. Or, just get the TXID with `tx.hash`.


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
