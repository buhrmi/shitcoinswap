module Utils
  def self.encrypt_key hex_key
    pubkey.public_encrypt(hex_key).unpack('H*').first
  end

  def self.private_encrypt memo
    privkey.private_encrypt(hex_key).unpack('H*').first
  end

  def self.public_decrypt hex
    pubkey.public_decrypt([hex_key].pack('H*'))
  end

  def self.decrypt_key hex_key
    privkey.private_decrypt([hex_key].pack('H*'))
  end

  private
  def self.pubkey
    @pubkey ||= OpenSSL::PKey::RSA.new File.read Rails.root.join('config/hotwallet.pub.pem')
  end

  def self.privkey
    @privkey ||= OpenSSL::PKey::RSA.new File.read Rails.root.join('config/hotwallet.priv.pem')
  end
end

