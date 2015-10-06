class Item < ActiveRecord::Base
  belongs_to :place, counter_cache: true

  acts_as_taggable

  validates :name, presence: true
  validates :cost, numericality: true, presence: false, allow_blank: true

  default_scope -> { order(id: :asc)}
end
