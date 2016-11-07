require 'devise/encryptor'

Devise::Encryptor.class_eval do
  class << self
    alias_method :orig_compare, :compare

    def compare(klass, hashed_password, password)
      return false if hashed_password.blank?

      if ::BCrypt::Password.valid_hash? hashed_password
        orig_compare(klass, hashed_password, password)
      else
        # monkey patch for support legacy MD5 hashed password
        password_digest = Digest::MD5.hexdigest password
        if password_digest == hashed_password
          return true
        else
          return false
        end
      end

    end
  end

end
