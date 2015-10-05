class Item < ActiveRecord::Base
  belongs_to :place, counter_cache: true

  validates :name, presence: true
  validates :cost, numericality: true
end
