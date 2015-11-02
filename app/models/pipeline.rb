class Pipeline < ActiveRecord::Base

  scope :pub, -> {where(public: true)}
  scope :belongs_to_user, ->(user) {where(owner: user)}

  belongs_to :owner, class_name: 'User'

  def accession
    "QP-#{self.id}"
  end

end
