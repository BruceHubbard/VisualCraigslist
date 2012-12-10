require 'nokogiri'
require 'open-uri'

class Listing
	attr_accessor :date, :title, :link, :price, :pics

	@@search_url = "http://%s.craigslist.org/search/%s?areaID=35&subAreaID=&query=%s&s=%s"
	@@page_size = 10

	def self.search (search_term, site, category, page_num)
		listings = []

		skip = page_num.to_i * @@page_size

		url = URI::encode(@@search_url % [site, category, search_term, skip])
		puts "URL: #{url}"

	    doc = Nokogiri::HTML.parse(open(url))

	    for listing_html in doc.css('p.row').take(@@page_size)
	    	listing = Listing.new
	    	listing.date = listing_html.css('.itemdate')[0].content.strip
	    	listing.title = listing_html.css('a')[0].content.strip
	    	listing.link = listing_html.css('a')[0]["href"]
	    	listing.price = listing_html.css('.itempp')[0].content.strip
	    	listing.price = "??" if listing.price.to_s == ''
	    	listing.pics = pics(listing.link)

	    	listings << listing
	    end

		listings
	end

	private

	def self.pics (url)
		Nokogiri::HTML.parse(open(url)).css('.tn a').collect {|img| img["href"]}
	end
end