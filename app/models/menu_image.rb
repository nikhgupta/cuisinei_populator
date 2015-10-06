class MenuImage < ActiveRecord::Base
  belongs_to :place
  self.inheritance_column = nil
end
