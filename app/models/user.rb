class User < ActiveRecord::Base
  has_many :workables, foreign_key: :locked_by, class_name: "Place"
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

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
end
