class PlacePolicy < ApplicationPolicy

  def index?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      @user.admin? ? scope.all : scope.where(locked_by: @user.id)
    end
  end
end

