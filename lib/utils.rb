# This module depends on the existence of an RSA keypair. To create this keypair, you can use the following commands
# ```
# -[ -f config/keys/hotwallet.priv.pem ] || openssl genrsa -out config/keys/hotwallet.priv.pem 2048
# -[ -f config/keys/hotwallet.pub.pem ] || openssl rsa -in config/keys/hotwallet.priv.pem -outform PEM -pubout -out config/keys/hotwallet.pub.pem
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
    @pubkey ||= OpenSSL::PKey::RSA.new File.read Rails.root.join('config/keys/hotwallet.pub.pem')
  end

  def self.privkey
    @privkey ||= OpenSSL::PKey::RSA.new File.read Rails.root.join('config/keys/hotwallet.priv.pem')
  end
end

