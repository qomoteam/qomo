module ScholarHelper
  def location_label(user)
    [user.profile.city, ISO3166::Country[user.profile.country]].reject {|e| e.blank?}.join(', ')
  end
end
