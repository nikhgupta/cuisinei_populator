class Item < ActiveRecord::Base
  belongs_to :place, counter_cache: true
end
