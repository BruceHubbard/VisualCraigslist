require 'nokogiri'
require 'open-uri'

class Listing
	attr_accessor :date, :title, :link, :pics
	@@search_url = "http://cincinnati.craigslist.org/search/?query=star+wars&catAbb=sss"
	@@image_base = "http://images.craigslist.org/"

	def self.search (search_term)
		listings = []
	    doc = Nokogiri::HTML.parse(open(@@search_url))
	    for listing_html in doc.css('p.row')
	    	listing = Listing.new
	    	listing.date = listing_html.css('.itemdate')[0].content.strip
	    	listing.title = listing_html.css('a')[0].content.strip
	    	listing.link = listing_html.css('a')[0]["href"]
	    	listing.pics = pics(listing.link)

	    	puts listing.inspect

	    	listings << listing
	    end
#	    listings = ButlerListingParser.new(doc.to_s).listings
#	    all_auctions = []
#	    
#	    for listing in listings do
#	      url = @@urlBase + listing.link
#	      all_auctions.concat(ButlerAuctionParser.new(Net::HTTP.get(URI.parse(url))).auctions)
#	    end
	    
#	    all_auctions		
#	    for link in @html.css('#AutoNumber1 a') do
#	      list << Listing.new(link["href"], link.content.gsub(/\n\t/, "").gsub(/\s+/, " ").strip)
#	    end
		listings
	end

	private

	def self.pics (url)
		pics = []

		detail_doc = Nokogiri::HTML.parse(open(url))

		for img in detail_doc.css('.tn a')
			pics << img["href"]
		end

		pics
	end
end