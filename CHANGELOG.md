# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

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
