require 'nokogiri'
require 'open-uri'

class Listing
	attr_accessor :date, :title, :link, :pics
	@@search_url = "http://cincinnati.craigslist.org/search/?query=%s&catAbb=sss"
	@@image_base = "http://images.craigslist.org/"

	def self.search (search_term)
		listings = []
	    doc = Nokogiri::HTML.parse(open(URI::encode(@@search_url % [search_term])))

	    for listing_html in doc.css('p.row').take(10)
	    	listing = Listing.new
	    	listing.date = listing_html.css('.itemdate')[0].content.strip
	    	listing.title = listing_html.css('a')[0].content.strip
	    	listing.link = listing_html.css('a')[0]["href"]
	    	listing.pics = pics(listing.link)

	    	puts listing.inspect

	    	listings << listing
	    end

		listings
	end

	private

	def self.pics (url)
		Nokogiri::HTML.parse(open(url)).css('.tn a').collect {|img| img["href"]}
	end
end