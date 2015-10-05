class Place < ActiveRecord::Base
  belongs_to :city, counter_cache: true
  belongs_to :locker, foreign_key: :locked_by, class_name: "User", counter_cache: :workables_count
  has_many :items

  accepts_nested_attributes_for :items, allow_destroy: true

  scope :pending,  -> { where(completed_at: nil) }
  scope :locked,   -> { where("locked_by IS NOT NULL") }
  scope :unlocked, -> { where(locked_by: nil) }

  def ref_url
    "http://zoma.to/r/#{ref_id}"
  end

  def title
    "#{attribute :title}, #{city.name}"
  end

  def location
    [lat, lng]
  end

  def locked_via(user)
    locked_via!(user) unless locked_by
  end

  def locked_via!(user)
    update_attribute :locked_by, user.id if user.present?
  end

  # TODO: Replace with JS map later.
  def static_map_url(options = {})
    url  = "http://maps.googleapis.com/maps/api/staticmap?"
    # url += "center=#{city.address}&"
    url += "zoom=14&size=#{options.fetch(:size, "640x480")}&"
    url += "maptype=#{options.fetch(:type, "roadmap")}&"
    url += "markers=color:#{options.fetch(:color, "red")}|#{location.join(",")}"
    # url += "&style=element:labels|visibility:off&style=element:geometry.stroke|visibility:off&style=feature:landscape|element:geometry|saturation:-100&style=feature:water|saturation:-100|invert_lightness:true&key=#{Rails.application.secrets.google_api_key}"
  end

  def completed?
    completed_at.present?
  end

  def pending?
    !completed?
  end

  def complete!
    self.update_attribute :completed_at, Time.now
    City.increment_counter :completed_places_count, city.id
  end

  def pending!
    self.update_attribute :completed_at, nil
    City.decrement_counter :completed_places_count, city.id
  end
end
