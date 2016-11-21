require 'digest/sha3'
require 'ethereum/base'
require 'ffi'
require 'money-tree'
require 'rlp'

module Eth
  REPLAYABLE_CHAIN_ID = 13

  autoload :Key, 'eth/key'
  autoload :OpenSsl, 'eth/open_ssl'
  autoload :Sedes, 'eth/sedes'
  autoload :Tx, 'eth/tx'
  autoload :Utils, 'eth/utils'

  class << self
    def configure
      yield(configuration)
    end

    def chain_id
      (configuration.chain_id || REPLAYABLE_CHAIN_ID).to_i
    end

    def v_base
      (chain_id * 2) + 1
    end

    def replayable_v_base
      (REPLAYABLE_CHAIN_ID * 2) + 1
    end

    def prevent_replays?
      chain_id != REPLAYABLE_CHAIN_ID
    end

    def replayable_v?(v)
      [replayable_v_base, replayable_v_base + 1].include? v
    end


    private

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :chain_id
  end
end
