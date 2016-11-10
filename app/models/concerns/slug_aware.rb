module SlugAware
  extend ActiveSupport::Concern

  included do
    before_save :update_slug

    def update_slug
      self.slug = self[self.class.slug_for].parameterize
      s = self.class.find_by_slug(self.slug)
      if s and s != self
        self.slug = self.slug + '-1'
      end
    end
  end

  class_methods do
    attr_accessor :slug_for

    def slug_aware(opts)
      self.slug_for = opts[:for]
    end
  end

end
