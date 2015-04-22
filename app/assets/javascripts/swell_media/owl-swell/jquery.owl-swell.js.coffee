
#= require ./owl-carousel/owl.carousel.js

syncPosition = ($that, currentItem) ->
	current = currentItem
	$that.find('.owl-item').removeClass('synced').eq(current).addClass 'synced'
	if $that.data('owlCarousel') != undefined
		center $that, current
	return

apply_center = ( owl ) ->
	return if owl == undefined
	#console.log('centering...', owl)
	#console.log(owl.visibleItems)
	if owl.visibleItems.length > 0
		center_i = Math.ceil( owl.visibleItems.length / 2 ) - 1
		#console.log(center_i, owl.visibleItems[center_i])
		owl.$owlItems.removeClass('owl-swell-center')
		$(owl.$owlItems[owl.visibleItems[center_i]]).addClass( 'owl-swell-center' )
		#console.log(center_i, owl.visibleItems[center_i])

center = ($that, number) ->
	that_visible = $that.data('owlCarousel').owl.visibleItems
	num = number
	found = false
	for i of that_visible
		if num == that_visible[i]
			found = true
	if found == false
		if num > that_visible[that_visible.length - 1]
			$that.trigger 'owl.goTo', num - that_visible.length + 2
		else
			if num - 1 == -1
				num = 0
			$that.trigger 'owl.goTo', num
	else if num == that_visible[that_visible.length - 1]
		$that.trigger 'owl.goTo', that_visible[1]
	else if num == that_visible[0]
		$that.trigger 'owl.goTo', num - 1
	return

$.owlswell = ( $this )->
	#console.log 'owlswell', $this[0]
	options = $this.data('owl')

	if $this.data('owl')['sync']
		#console.log 'owlswell after init'
		options['afterInit'] = (el) ->
			el.find(".owl-item").eq(0).addClass("synced")
			apply_center( owl )
	else
		#console.log 'owlswell after init'
		options['afterInit'] = (el) ->
			apply_center( owl )

	if $this.data('owl')['synced']
		$that = $($this.data('owl')['synced'])

		#console.log 'owlswell after action'
		options['afterAction'] = (el)->
			syncPosition($that, @currentItem)
			apply_center( owl )
		$that.on 'click', '.owl-item', (e) ->
			return if $(e.target).parents('a').length > 0 ||  $(e.target).is('a')
			e.preventDefault()
			number = $(this).data('owlItem')
			$this.trigger 'owl.goTo', number
			return
	else
		#console.log 'owlswell after action'
		options['afterAction'] = (el)->
			apply_center( owl )

	#console.log 'owlswell before move'
	beforeMove = options['beforeMove']
	options['beforeMove'] = (el)->
		owl.$owlItems.removeClass('owl-swell-center') if owl
		beforeMove(el) if beforeMove
		$('iframe.track_video:data(tv-player)', $this).each ->
			$(this).data('tv-player').pauseVideo()

	$this.owlCarousel(options);


	owl = $this.data('owlCarousel');
	owl.jumpTo(options.start_position) if options.start_position

	apply_center( owl )

$.fn.owlswell = ()->
	selector = $(this)
	selector.each ()->
		$this = $(this)

		$.owlswell $this


$(document).ready ->

	$("[data-owl]").owlswell()