class UserPolicy < ApplicationPolicy

  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.all : scope.where(id: @user)
    end
  end
end

