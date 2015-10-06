class Item < ActiveRecord::Base
  belongs_to :place, counter_cache: true

  acts_as_taggable

  validates :name, presence: true
  validates :cost, numericality: true
end
