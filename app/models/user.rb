class User < ActiveRecord::Base
  has_many :workables, foreign_key: :locked_by, class_name: "Place"
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  validates :per_item_earnings, numericality: true, allow_blank: true

  def to_s
    email
  end

  def pending_workables
    workables.pending.reload
  end

  def has_pending_workable?
    pending_workables.any?
  end

  def has_no_pending_workable?
    !has_pending_workable?
  end

  def total_items_added
    workables.map(&:items_count).sum
  end

  def on_per_item_basis?
    !admin? && per_item_earnings.to_f > 0
  end

  def earnings
    total_items_added * per_item_earnings
  end
end
