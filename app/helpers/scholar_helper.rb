module ScholarHelper
  def location_label(user)
    [user.profile.location, ISO3166::Country[user.profile.country]].reject {|e| e.blank?}.join(', ')
  end
end
