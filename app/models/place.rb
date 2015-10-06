class Place < ActiveRecord::Base
  belongs_to :city, counter_cache: true
  belongs_to :locker, foreign_key: :locked_by, class_name: "User", counter_cache: :workables_count
  has_many :items
  has_many :menu_images, dependent: :destroy

  accepts_nested_attributes_for :items, allow_destroy: true

  scope :pending,  -> { where(completed_at: nil) }
  scope :locked,   -> { where("locked_by IS NOT NULL") }
  scope :unlocked, -> { where(locked_by: nil) }

  def ref_url
    "http://zoma.to/r/#{ref_id}"
  end

  def complete_ref_url
    html = Nokogiri::HTML raw_snippet
    html.search("a.result-title").attr("href").text.strip
  end

  def menu_url
    "#{complete_ref_url}/menu"
  end

  def title
    "#{attribute :title}, #{city.try :name}"
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
    url += "zoom=14&size=#{options.fetch(:size, "640x480")}&"
    url += "maptype=#{options.fetch(:type, "roadmap")}&"
    url += "markers=color:#{options.fetch(:color, "red")}|#{location.join(",")}"
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

  def fetch_images
    return if menu_images.any?
    images = ZomatoMenuScraperService.new(ref_menu_url).run
    resource.menu_images.create images if images && images.any?
  end
end
