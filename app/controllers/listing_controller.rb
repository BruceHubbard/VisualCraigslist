class ListingController < ApplicationController
	def search
		render :json => Listing.search(params[:searchTerm], params[:baseSite])
	end
end
