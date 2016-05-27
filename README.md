# Ethereum::Tx

A simple, light weight, library to build and sign Ethereum transactions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ethereum-tx'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ethereum-tx

## Usage

### Keys
Create a new key:
```
key = Ethereum::Key.new
```
Or import and existing one:
```
old_key = Ethereum::Key.new private_key
```

### Transactions

Build a transaction from scratch:
```
tx = Ethereum::Tx.new to: key.address, gas_price: 25_000, gas_limit: 25_000
tx.data = 'abcdef' #optional
tx.value = 1_000_000_000_000 #optional
```
Or decode an encoded raw transaction:
```
tx = Ethereum::Tx.decode hex
```

Then sign the transaction:
```
tx.sign key
```
Finally you can broadcast the raw transaction, `tx.encoded`, to your Ethereum node.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/se3000/ethereum-tx.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODO
- Better test suite.
- Expose API for HD keys.
- Separate out code pulled from [bitcoin-ruby](https://github.com/lian/bitcoin-ruby) and [ruby-ethereum](github.com/janx/ruby-ethereum) into their own gems to eliminate duplication.
- Support signing with [libsecp256k1](https://github.com/bitcoin-core/secp256k1).
