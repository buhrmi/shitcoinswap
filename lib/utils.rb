# This module depends on the existence of an RSA keypair. To create this keypair, you can use the following commands
# ```
# [ -f config/keys/wallet.priv.pem ] || openssl genrsa -out config/keys/wallet.priv.pem 2048
# [ -f config/keys/wallet.pub.pem ] || openssl rsa -in config/keys/wallet.priv.pem -outform PEM -pubout -out config/keys/wallet.pub.pem
# ```

module Utils
  def self.encrypt_key hex_key
    pubkey.public_encrypt(hex_key).unpack('H*').first
  end

  def self.decrypt_key hex_key
    privkey.private_decrypt([hex_key].pack('H*'))
  end

  def self.private_encrypt memo
    privkey.private_encrypt(memo).unpack('H*').first
  end

  def self.public_decrypt hex
    pubkey.public_decrypt([hex].pack('H*'))
  end

  private
  def self.pubkey
    @pubkey ||= OpenSSL::PKey::RSA.new File.read Rails.root.join('config/keys/wallet.pub.pem')
  end

  def self.privkey
    @privkey ||= OpenSSL::PKey::RSA.new File.read Rails.root.join('config/keys/wallet.priv.pem')
  end
end

