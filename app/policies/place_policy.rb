class PlacePolicy < ApplicationPolicy

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
