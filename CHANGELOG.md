# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.4.6]

### Added
- Support scrypt private key decryption

## [0.4.5]

### Changed
- Further improve Open SSL configurability

## [0.4.4]

### Changed
- Support old versions of SSL to help avoid preious breaking changes

## [0.4.3]

### Added
- Eth::Key::Encrypter class to handle encrypting keys.
- Eth::Key.encrypt as a nice wrapper around Encrypter class.
- Eth::Key::Decrypter class to handle encrypting keys.
- Eth::Key.decrypt as a nice wrapper around Decrypter class.

## [0.4.2]

### Added
- Address#valid? to validate EIP55 checksums.
- Address#checksummed to generate EIP55 checksums.
- Utils.valid_address? to easily validate EIP55 checksums.
- Utils.format_address to easily convert an address to EIP55 checksummed.

### Changed
- Dependencies no longer include Ethereum::Base. Eth now implements those helpers directly and includes ffi, digest-sha3, and rlp directly.


## [0.4.1]

### Changed
- Tx#hash includes the '0x' hex prefix.

## [0.4.0]

### Added
- Tx#data_bin returns the data field of a transaction in binary.
- Tx#data_hex returns the data field of a transaction as a hexadecimal string.
- Tx#id is an alias of Tx#hash

### Changed
- Tx#data is configurable to return either hex or binary: `config.tx_data_hex = true`.
- Tx#hex includes the '0x' hex prefix.
- Key#address getter is prepended by '0x'.
- Extract public key to address method into Utils.public_key_to_address.
- Tx#from returns an address instead of a public key.
- Chain ID is updated to the later version of the spec.
