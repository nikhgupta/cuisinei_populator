require 'open-uri'

class GeocoderService
  class Error < StandardError; end

  def initialize(address, options = {})
    @address, @options = address, options
  end

  def run
    fetch_geocoding_response
    raise_errors_if_any!

    {
      lat_pos: location["geometry"]["location"]["lat"],
      lng_pos: location["geometry"]["location"]["lng"],
      lat_min: location["geometry"]["viewport"]["southwest"]["lat"],
      lng_min: location["geometry"]["viewport"]["southwest"]["lng"],
      lat_max: location["geometry"]["viewport"]["northeast"]["lat"],
      lng_max: location["geometry"]["viewport"]["northeast"]["lng"],
    }
  end

  private

  def location
    @location ||= @json["results"][0]
  end

  def raise_errors_if_any!
    raise GeocoderService::Error, "Invalid response received" unless success?
    raise GeocoderService::Error, "No results found" if no_results?
  end

  def no_results?
    @json["results"].count == 0
  end

  def fetch_geocoding_response
    url  = "https://maps.googleapis.com/maps/api/geocode/json"
    url += "?address=#{URI.encode @address}&key=#{Rails.application.secrets.google_api_key}"
    @json = JSON.parse open(url).read
  end

  def success?
    @json["status"] == "OK"
  end
end
