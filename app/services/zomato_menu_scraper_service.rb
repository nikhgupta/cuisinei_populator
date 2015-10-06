require 'nokogiri'

class ZomatoMenuScraperService
  def initialize(url, options = {})
    @url = "#{url}/menu"
    @options = options
  end

  def run
    return unless json
    json.map do |data|
      {
        url: data["url"],
        type: data["real_menu_type"].downcase,
        consumer_upload: data["consumer_upload"] > 0
      }
    end
  end

  private

  def html
    @html ||= open(@url).read
  end

  def json
    return @json if @json
    return if html.blank?
    match = html.match(/zomato.menuPages = (.*?);/mi)
    return if match.blank?
    @json = JSON.parse match[1]
  end
end
