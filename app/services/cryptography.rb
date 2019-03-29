class Cryptography
  def initialize(file:)
    @file = file
  end

  def encrypt
    cipher.encrypt
    cipher.iv = encryption_iv
    cipher.key = encryption_key
    encrypted_data = cipher.update(@file) + cipher.final
    encrypted_data.unpack1('H*')
  end

  def decrypt
    cipher.decrypt
    cipher.iv = encryption_iv
    cipher.key = encryption_key
    data = [@file].pack('H*').unpack('C*').pack('c*')
    cipher.update(data) + cipher.final
  end

  def cipher
    @cipher ||= OpenSSL::Cipher.new 'AES-256-CBC'
  end

  def encryption_iv
    ENV['ENCRYPTION_IV']
  end

  def encryption_key
    ENV['ENCRYPTION_KEY']
  end
end
