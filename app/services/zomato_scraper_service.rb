require 'open-uri'

class ZomatoScraperService
  class Error < StandardError; end

  def initialize(options = {})
    @options = options
    @lat_min = options[:lat_min]
    @lng_min = options[:lng_min]
    @lat_max = options[:lat_max]
    @lng_max = options[:lng_max]
    @page    = options[:page]
  end

  def run
    json = JSON.parse open(url).read
    raise Error, "No places found" if json["mapData"].blank?

    json["mapData"].values.map do |data|
      snippet = Nokogiri::HTML(data["snippet"])
      sanitized_item(data, snippet)
    end
  end

  private

  def url
    "https://www.zomato.com/php/search_results.php?range=#{@lat_min},#{@lng_min},#{@lat_max},#{@lng_max}&page=#{@page+1}"
  end

  def sanitized_item(data, snippet)
    {
      title: snippet.search("a.result-title").text.strip,
      address: snippet.search(".search-result-address").text.strip,
      lat: data["lat"],
      lng: data["lon"],
      establishment_name: data["establishment_name"],
      ref_id: data["res_id"].to_i,
      ref_rating: data["rating"].to_f,
      ref_votes_count: snippet.search(".rating-rank").text.gsub("votes", '').strip.to_i,
      raw_snippet: data["snippet"]
    }
  end
end
