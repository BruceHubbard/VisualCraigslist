require 'nokogiri'
require 'open-uri'

class Listing
	attr_accessor :date, :title, :link, :pics

	@@search_url = "http://%s.craigslist.org/search/?areaID=35&subAreaID=&query=%s&catAbb=sss&s=%s"
	@@image_base = "http://images.craigslist.org/"
	@@page_size = 20

	def self.search (search_term, site, page_num)
		listings = []

		skip = page_num.to_i * @@page_size + 1

		url = URI::encode(@@search_url % [site, search_term, skip])
		puts "URL: #{url}"

	    doc = Nokogiri::HTML.parse(open(url))

	    for listing_html in doc.css('p.row').take(@@page_size)
	    	listing = Listing.new
	    	listing.date = listing_html.css('.itemdate')[0].content.strip
	    	listing.title = listing_html.css('a')[0].content.strip
	    	listing.link = listing_html.css('a')[0]["href"]
	    	listing.pics = pics(listing.link)

	    	#puts listing.inspect

	    	listings << listing
	    end

		listings
	end

	private

	def self.pics (url)
		Nokogiri::HTML.parse(open(url)).css('.tn a').collect {|img| img["href"]}
	end
end