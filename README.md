# Eth

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
  data: 'abcdef',
  gas_limit: 3_141_592,
  gas_price: 20_000_000_000,
  nonce: 0,
  to: key.address,
  value: 1_000_000_000_000,
})
```
Or decode an encoded raw transaction:
```ruby
tx = Eth::Tx.decode hex
```

### Configure
In order to prevent replay attacks, you must specify which Ethereum chain your transactions are created for. See [EIP 155](https://github.com/ethereum/EIPs/issues/155) for more detail.
```
Eth.configure do |config|
  config.chain_id = 18 #defaults to 13
end
```

Then sign the transaction:
```ruby
tx.sign key
```
Get the raw transaction with `tx.hex`, and broadcast it through any Ethereum node. Or, just get the TXID with `tx.hash`.


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/se3000/ethereum-tx.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODO
- Better test suite.
- Expose API for HD keys.
- Support signing with [libsecp256k1](https://github.com/bitcoin-core/secp256k1).
