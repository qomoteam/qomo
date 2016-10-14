module ScholarHelper
  def location_label(user)
    [user.location, ISO3166::Country[user.country]].reject {|e| e.blank?}.join(', ')
  end
end
