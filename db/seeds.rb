# require our service as it won't get eager loaded in DEVELOPMENT env.
require Rails.root.join("app", "services", "geocoder_service.rb").to_s

puts "Seeding.."

puts "-- Creating some users.."
pass = ENV['DEFAULT_PASSWORD'] ||= "password"

user = User.find_or_initialize_by(email: 'admin@example.com')
user.password = user.password_confirmation = pass
user.admin = true
user.save

user = User.find_or_initialize_by(email: 'test@example.com')
user.password = user.password_confirmation = pass
user.admin = false
user.save

puts "-- Adding cities to the database.."
file = Rails.root.join("data", "cities.yml")
data = YAML.load_file file
data.each do |country, states|
  states.each do |state, cities|
    cities.each do |city, info|
      ActiveRecord::Base.transaction do
        puts "Adding info for: #{city}, #{state}, #{country}"
        city = City.find_or_initialize_by(name: city.titleize, state: state.titleize, country: country.titleize)
        info = info.merge(priority: 1) if ENV['PRIORITIZED_CITIES'].downcase.split(",").include?(city.name.downcase)
        city.update_attributes(info)

        next unless city.requires_geocoding?

        begin
          response = GeocoderService.new(city.address, administrative_area_level_2: city.name).run
          city.update_attributes response.merge(geocoded_at: Time.now)
        rescue GeocoderService::Error => e
          puts "\e[33m[Warning]: #{e.message} when geocoding: #{city.address}\e[0m"
        end
      end
    end
  end
end

puts "Finished.."
