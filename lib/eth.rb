require 'digest/sha3'
require 'ethereum/base'
require 'ffi'
require 'money-tree'
require 'rlp'

module Eth

  BYTE_ZERO = "\x00".freeze
  GTXCOST = 21000       # TX BASE GAS COST
  GTXDATANONZERO = 68   # TX DATA NON ZERO BYTE GAS COST
  GTXDATAZERO = 4       # TX DATA ZERO BYTE GAS COST
  SECP256K1_N = 115792089237316195423570985008687907852837564279074904382605163141518161494337
  UINT_MAX = 2**256 - 1

  autoload :Key, 'eth/key'
  autoload :OpenSsl, 'eth/open_ssl'
  autoload :Sedes, 'eth/sedes'
  autoload :Tx, 'eth/tx'
  autoload :Utils, 'eth/utils'

  class ValidationError < StandardError; end
  class InvalidTransaction < ValidationError; end

end
