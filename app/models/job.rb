class Job < ActiveRecord::Base

  enum status: {
           UNKNOWN: 0,
           READY: 1,
           RUNNING: 2,
           SUCCESS: 3,
           FAIL: 4,
           SUSPEND: 5
       }

  belongs_to :user

end
