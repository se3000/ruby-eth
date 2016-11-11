module Eth
  class Secp256k1
    extend FFI::Library

    ffi_lib 'bin/secp256k1.so'

    PUBKEY_BYTES = 64
    RECOVERABLE_SIGNATURE_BYTES = 65

    class Pubkey < FFI::Struct
      layout :data, [:uchar, PUBKEY_BYTES]
    end

    class ECDSARecoverableSignature < FFI::Struct
      layout :data, [:uchar, RECOVERABLE_SIGNATURE_BYTES]
    end

    attach_function :secp256k1_context_create,
      [:int],     # unsigned int flag
      :pointer

    attach_function :secp256k1_context_destroy,
      [:pointer], # secp256k1_context* ctx
      :void

    attach_function :secp256k1_ecdsa_sign_recoverable,
      [:pointer,  # const secp256k1_context* ctx
       :pointer,  # secp256k1_ecdsa_signature *sig
       :pointer,  # const unsigned char *msg32
       :pointer,  # const unsigned char *seckey
       :pointer,  # secp256k1_nonce_function noncefp
       :pointer], # const void *ndata
       :int

    attach_function :secp256k1_ecdsa_recover,
      [:pointer,  # const secp256k1_context* ctx
       :pointer,  # secp256k1_pubkey *pubkey
       :pointer,  # const secp256k1_ecdsa_recoverable_signature *sig
       :pointer], # const unsigned char *msg32
       :int

    # FFI does not support C directives, so we copy some context flags from secp256k1
    SECP256K1_FLAGS_TYPE_CONTEXT = (1 << 0)
    SECP256K1_FLAGS_BIT_CONTEXT_VERIFY = (1 << 8)
    SECP256K1_FLAGS_BIT_CONTEXT_SIGN = (1 << 9)

    SECP256K1_CONTEXT_NONE = (SECP256K1_FLAGS_TYPE_CONTEXT)
    SECP256K1_CONTEXT_SIGN = (SECP256K1_FLAGS_TYPE_CONTEXT | SECP256K1_FLAGS_BIT_CONTEXT_SIGN)
    SECP256K1_CONTEXT_VERIFY = (SECP256K1_FLAGS_TYPE_CONTEXT | SECP256K1_FLAGS_BIT_CONTEXT_VERIFY)

    def self.sign_compact(hash, private_key)
      # ctx is a pointer to the context object, initialized for signing
      ctx = secp256k1_context_create SECP256K1_CONTEXT_SIGN

      # sig is a pointer to the array where the signature will be placed
      sig = ECDSARecoverableSignature.new

      # msg32 is a pointer to the 32-byte hash that is to be signed
      msg32 = FFI::MemoryPointer.new(:uchar, 32)
      msg32.write_array_of_uchar(hash.split("").map(&:ord))

      # seckey is a pointer to a 32-byte secret key
      private_key = [private_key].pack("H*") if private_key.bytesize >= 64
      seckey = FFI::MemoryPointer.new(:uchar, 32)
      seckey.write_array_of_uchar(private_key.split("").map(&:ord))

      # If secp256k1_nonce_function is NULL, then secp256k1 will default to an implementation of
      # RFC6979 (using HMAC-SHA256) as the nonce generation function. Similarily, ndata is used
      # as arbitrary data by the nonce function.
      nonce_func = nil
      ndata = FFI::MemoryPointer.new(:uchar, 32)
      ndata.put_bytes(0, SecureRandom.random_bytes(32))

      # If it returns 0, the private key or nonce was invalid
      if secp256k1_ecdsa_sign_recoverable(ctx, sig.pointer, msg32, seckey, nonce_func, ndata) == 0
        raise ArgumentError, "Invalid private key #{private_key} given."
      end

      secp256k1_context_destroy(ctx)
      sig[:data].to_a.pack("C*")
    end

    def self.recover_compact(hash, signature)
      return false if signature.bytesize != RECOVERABLE_SIGNATURE_BYTES

      # ctx is a pointer to the context object, initialized for recovering
      ctx = secp256k1_context_create SECP256K1_CONTEXT_VERIFY

      # pubkey is a pointer to the recovered public key
      pubkey = Pubkey.new

      # sig is the recoverable signature
      sig = ECDSARecoverableSignature.new
      signature.unpack("C*").each_with_index do |n, i|
        sig[:data][i] = n
      end

      # msg32 is the signed hash
      msg32 = FFI::MemoryPointer.new(:uchar, 32)
      msg32.write_array_of_uchar(hash.split("").map(&:ord))

      # If it returns 0, the hash or signature was invalid
      if secp256k1_ecdsa_recover(ctx, pubkey.pointer, sig.pointer, msg32) == 0
        raise ArguementError, "Invalid hash or signature given."
      end

      secp256k1_context_destroy(ctx)
      pubkey[:data].to_a.pack('C*').unpack('H*')[0]
    end
  end
end
