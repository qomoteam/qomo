module ActiveRecord
  class Base

    def update_record_without_timestamping
      class << self
        def record_timestamps; false; end
      end

      save!

      class << self
        def record_timestamps; super ; end
      end
    end

  end
end

class String
  require 'uri'
  def add_param(params)
    uri = URI(self)
    up = URI.decode_www_form(uri.query || "")
    up += params.to_a
    uri.query = URI.encode_www_form(up)
    uri.to_s
  end
end

class File < IO

  def self.is_rdout?(path)
    File.directory? path and File.exist?(File.join path, '_SUCCESS')
  end

  def is_rdout?
    File.is_rdout? self.path
  end

end
