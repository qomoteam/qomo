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

module StringToBoolean
  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end
class String; include StringToBoolean; end

module BooleanToBoolean
  def to_bool;return self; end
end

class TrueClass; include BooleanToBoolean; end
class FalseClass; include BooleanToBoolean; end
