class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, [Pipeline, Tool], shared: true

    return unless user

    if user.admin?
      can :manage, :all
      return
    end

    can [:my, :create], [Pipeline, Tool]
    can [:run, :bookmark], [Pipeline, Tool], shared: true


    cannot [:my, :create, :bookmark], [Pipeline, Tool] if user.guest?

  end
end
