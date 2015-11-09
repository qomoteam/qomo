module Statusaware
  extend ActiveSupport::Concern

  included do
    enum status: {
        waiting: 0,
        ready: 1,
        running: 2,
        failed: 3,
        success: 4,
        suspend: 5
    }
  end

end