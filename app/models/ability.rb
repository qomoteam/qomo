class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Pipeline, Tool, Filerecord], shared: true

    return unless user

    if user.is_admin?
      can :manage, :all
      return
    end

    can :manage, [Pipeline, Tool, Filerecord], owner_id: user.id

    can [:my, :create], [Pipeline, Tool]
    can [:run, :bookmark], [Pipeline, Tool], shared: true

    cannot [:my, :create, :bookmark], [Pipeline, Tool] if user.is_guest?

  end
end
