module AccessionAware
  extend ActiveSupport::Concern

  included do
    before_save :set_accession

    def accession_label
      "#{self.class.accession_prefix}#{sprintf '%06d', self.accession}"
    end

    def set_accession
      if self.accession.blank? and self.shared
        self.accession = (self.class.maximum(:accession) || 0) + 1
      end
    end
  end

  class_methods do
    attr_accessor :accession_prefix

    def validate_accession_label?(label)
      label.upcase.starts_with? self.accession_prefix
    end

    def label_to_accession(label)
      label[self.accession_prefix.length..-1].to_i
    end

    def accession_aware(opts)
      self.accession_prefix = opts[:prefix]
    end

    def find_by_accession_label(label)
      return nil unless validate_accession_label? label
      accession = label_to_accession(label)
      self.find_by_accession accession
    end
  end
end
