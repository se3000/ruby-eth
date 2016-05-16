require 'ffi'
require 'money-tree'
require 'rlp'

module Ethereum

  BYTE_ZERO = "\x00".freeze
  GTXCOST = 21000       # TX BASE GAS COST
  GTXDATANONZERO = 68   # TX DATA NON ZERO BYTE GAS COST
  GTXDATAZERO = 4       # TX DATA ZERO BYTE GAS COST
  UINT_MAX = 2**256 - 1

  autoload :Key, 'ethereum/key'
  autoload :OpenSsl, 'ethereum/open_ssl'
  autoload :Sedes, 'ethereum/sedes'
  autoload :Tx, 'ethereum/tx'
  autoload :Utils, 'ethereum/utils'
  autoload :VERSION, 'ethereum/version'

  class ValidationError < StandardError; end
  class InvalidTransaction < ValidationError; end

end
