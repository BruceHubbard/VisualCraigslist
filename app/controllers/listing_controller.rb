class ListingController < ApplicationController
	def search
		render :json => Listing.search(params[:searchTerm], params[:baseSite], params[:category], params[:pageNum] || 0)
	end
end
