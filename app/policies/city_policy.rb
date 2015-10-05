class CityPolicy < ApplicationPolicy

  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.all : scope.none
    end
  end
end

