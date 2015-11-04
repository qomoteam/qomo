module Statusaware
  extend ActiveSupport::Concern

  included do
    enum status: {
        UNKNOWN: 0,
        READY: 1,
        RUNNING: 2,
        FAIL: 3,
        SUCCESS: 4,
        SUSPEND: 5
    }
  end

end