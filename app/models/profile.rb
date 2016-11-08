class Profile < ApplicationRecord

  belongs_to :user

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def displayed_name
    if full_name.blank?
      self.user.username
    else
      full_name
    end
  end

end
