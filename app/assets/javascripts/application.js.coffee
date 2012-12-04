# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require_tree .
#= require handlebars-1.0.rc.1
#= require bootstrap.min

mockItems = [{"date":"Nov 26","title":"2 STAR WARS BOOKS","link":"http://cincinnati.craigslist.org/clt/3406696352.html","pics":["http://images.craigslist.org/3I33M63Jd5Gf5Kf5F3cbd3e2ea62810331757.jpg","http://images.craigslist.org/3M83J53N15Ed5Kc5H7cbd2479c217d31c156f.jpg"]},{"date":"Nov 26","title":"STAR WARS ULTIMATE LIGHTSABERS","link":"http://cincinnati.craigslist.org/tad/3435708836.html","pics":[]},{"date":"Nov 26","title":"WE BUY TOYS, VIDEO GAMES AND COLLECTIONS! PAYING CASH!","link":"http://cincinnati.craigslist.org/wan/3422990023.html","pics":[]},{"date":"Nov 26","title":"Nintendo Gameboy and 24 GAMES!!","link":"http://cincinnati.craigslist.org/tag/3435311497.html","pics":["http://images.craigslist.org/3Fc3Le3pb5Ib5H95Mecbq0603d221e6671221.jpg"]},{"date":"Nov 26","title":"VINTAGE 1977 STAR WARS POSTERS","link":"http://cincinnati.craigslist.org/clt/3429625230.html","pics":["http://images.craigslist.org/3J13o33Hd5N15Fb5J6cbn0fa55b795f741efb.jpg","http://images.craigslist.org/3K53M13p45I95N15U0cbn9f47aea43948119e.jpg"]},{"date":"Nov 26","title":"Princess Leia, Six Million Dollar Man and Bionic Woman","link":"http://cincinnati.craigslist.org/tag/3435295113.html","pics":["http://images.craigslist.org/3F73M33L65I45G65J3cbqd362e737847114ba.jpg","http://images.craigslist.org/3La3Fd3H85E85M25J2cbq0f7a549feec11a6b.jpg","http://images.craigslist.org/3Ke3F53I15La5N35Mccbq704a5601956a1273.jpg"]},{"date":"Nov 26","title":"ATARI 2600 Complete System with 35 Games","link":"http://cincinnati.craigslist.org/vgm/3435247274.html","pics":[]},{"date":"Nov 26","title":"Lots of Wii Games!!","link":"http://cincinnati.craigslist.org/vgm/3435234252.html","pics":["http://images.craigslist.org/3K43M43J25E85Kb5Mecbq1ce6c9722a1411e2.jpg"]},{"date":"Nov 26","title":"VINTAGE Darth Vader Star Wars Carry Case like new!!","link":"http://cincinnati.craigslist.org/tag/3426520791.html","pics":["http://images.craigslist.org/3Eb3n43L75N85Gc5J5cblc38dd67ff1d61bd1.jpg","http://images.craigslist.org/3L43Mb3Jd5Y05Ec5M4cbl6cfc69dcec361f4d.jpg"]},{"date":"Nov 25","title":"Wanted Kenner Employee Star Wars Toys/ Samples","link":"http://cincinnati.craigslist.org/clt/3421988601.html","pics":["http://images.craigslist.org/3G33L43N65N65E25Mccbj352f651892211018.jpg","http://images.craigslist.org/3Kc3L63N15I15L75M2cbj2b2f2adea46819d9.jpg","http://images.craigslist.org/3E43Md3J35N75Ge5U6cbjbd81363c53ad10dd.jpg","http://images.craigslist.org/3Kd3I13J65Nd5Z45K1cbj1540ce80e8f914dd.jpg","http://images.craigslist.org/3F93Me3J25N65Ga5J2cbj04acd937a3681a6b.jpg"]}];

Handlebars.registerHelper('thumbnail', (context) ->
  return context.replace(".org/", ".org/thumb/")
)

Handlebars.registerHelper('ifMoreThanOne', (array, block) ->
	if(array && array.length > 1)
		block.fn(this)
	else 
		""
)

class ListingView
	constructor: (searchType) ->
		me = @
		@term = searchType.searchTerm
		@city = searchType.city
		@category = searchType.category

		@page = 0
		@listingTpl = Handlebars.compile($("#listingTpl").html())
		@paging = false

		spinner = @spinner = $('<div class="spinner"><img src="assets/loading_animation.gif"/></div>')
		el = @el = $("<div class='listings'></div>")

		$('section.body').html(@el)

		@addEvents()
		@nextPage(() -> el.slideDown())

	markAsObsolete: () ->
		#put modal on top with processing wheel

	nextPage: (cb) ->
		me = @
		@paging = true
		
		listingModel.getItems(@term, @city, @category, @page, (data) ->
			me.spinner.detach()
			$('.collapse').collapse('hide')
			$('header button').css('display', 'inline-block');
			$('header .processing').hide()


			if(cb)
				cb()

			if(data && data.length > 0) 
				me.addItems(data)
				me.paging = false
				me.page += 1
				me.el.append(me.spinner)
				me.checkForNewPage()
			else
				me.el.append("<h3>No More Listings</h3>")
		)


	addEvents: () ->
		me = @
		@el.on('mouseover', '.info .thumbs img', () ->
			new_url = $(@).attr('src').replace("/thumb", "")
			listing = $(@).closest('.listing')
			listing.find('a img').attr('src', new_url)
		)

		$(window).on('scroll', () ->
			me.checkForNewPage()
		)

	checkForNewPage: () ->
		me = @
		if(isScrolledIntoView(me.spinner) && !me.paging)
			me.nextPage()

	addItems: (items) ->
		if items
			for item in items
				@el.append(@listingTpl(item))
		@el.append(@spinner)

listingModel = {
	getItems: (term, site, category, page, cb) ->
		$.ajax({
			url: 'listing/search',
			type: 'post',
			data: {searchTerm: term, baseSite: site, category: category, pageNum: page},
			success: cb,
			error: () ->
				alert("Could not retrieve items, most likely Craigslist has temporarily banned my app, try again later")
				cb()
		})
		#cb(mockItems)
}

isScrolledIntoView = (elem) ->
    docViewTop = $(window).scrollTop();
    docViewBottom = docViewTop + $(window).height();

    elemTop = $(elem).offset().top;
    elemBottom = elemTop + $(elem).height();

    return elemTop <= docViewBottom

$ ->
	currentListingView = null

	if(sessionStorage && lastSearch = sessionStorage.getItem("lastSearch"))
		lastSearch = JSON.parse(lastSearch)
		$('header input').val(lastSearch.searchTerm)
		$('header select[name="site"]').val(lastSearch.city)
		$('header select[name="category"]').val(lastSearch.category)

	$('header .search').click(() ->
		$(@).closest('form').submit()
	);

	$('header form').submit((e) ->
		e.preventDefault();
		$('header button').hide();
		$('header .processing').show();

		searchType = {
			searchTerm: $('header input').val()
			city: $('header select[name="site"]').val()
			category: $('header select[name="category"]').val()
		}

		if currentListingView
			currentListingView.markAsObsolete()

		if sessionStorage
			sessionStorage.setItem("lastSearch", JSON.stringify(searchType))

		currentListingView = new ListingView(searchType)
	)



