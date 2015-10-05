# For backend only.
#
class City < ActiveRecord::Base

  has_many :places

  scope :geocoded, -> {where("geocoded_at IS NOT NULL AND geocoded_at >= ?", 1.month.ago)}
  scope :require_geocoding, -> {where("geocoded_at IS NULL OR geocoded_at < ?", 1.month.ago)}
  scope :completed, ->{where("completed_at IS NOT NULL")}
  scope :pending, ->{where(completed_at: nil)}

  def self.which_require_more_places_covered
    self
      .geocoded
      .pending
      .where("completed_places_count < ?", ENV['MIN_COVERAGE_PER_CITY'].to_i)
      .order(priority: :desc, population: :desc, completed_places_count: :desc)
  end

  def address
    "#{name}, #{state}, #{country}"
  end

  def bounds
    { lat_min: lat_min, lng_min: lng_min, lat_max: lat_max, lng_max: lng_max }
  end

  def requires_geocoding?
    geocoded_at.blank? || geocoded_at < 1.month.ago
  end

  def pending_places
    places.pending.unlocked
  end

  def has_pending_place?
    pending_places.reload.any?
  end

  def has_no_pending_place?
    !has_pending_place?
  end
end
