class CityPolicy < ApplicationPolicy

  def create?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.all : nil
    end
  end
end

