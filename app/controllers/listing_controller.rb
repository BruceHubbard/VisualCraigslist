class ListingController < ApplicationController
	def search
		render :json => Listing.search(params[:searchTerm])
	end
end
