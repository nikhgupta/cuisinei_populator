class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :workables, foreign_key: :locked_by, class_name: "Place"

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
