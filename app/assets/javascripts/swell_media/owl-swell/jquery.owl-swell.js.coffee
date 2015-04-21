
#= require ./owl-carousel/owl.carousel.js

syncPosition = ($that, currentItem) ->
	current = currentItem
	$that.find('.owl-item').removeClass('synced').eq(current).addClass 'synced'
	if $that.data('owlCarousel') != undefined
		center $that, current
	return

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
	options = $this.data('owl')

	if $this.data('owl')['sync']
		options['afterInit'] = (el) ->
			el.find(".owl-item").eq(0).addClass("synced")

	if $this.data('owl')['synced']
		$that = $($this.data('owl')['synced'])

		options['afterAction'] = (el)->
			syncPosition($that, @currentItem)
		$that.on 'click', '.owl-item', (e) ->
			return if $(e.target).parents('a').length > 0 ||  $(e.target).is('a')
			e.preventDefault()
			number = $(this).data('owlItem')
			$this.trigger 'owl.goTo', number
			return

	beforeMove = options['beforeMove']
	options['beforeMove'] = (el)->
		beforeMove(el) if beforeMove
		$('iframe.track_video:data(tv-player)', $this).each ->
			$(this).data('tv-player').pauseVideo()

	$this.owlCarousel(options);


	owl = $this.data('owlCarousel');
	owl.jumpTo(options.start_position) if options.start_position

$.fn.owlswell = ()->
	selector = $(this)
	selector.each ()->
		$this = $(this)

		$.owlswell $this


$(document).ready ->

	$("[data-owl]").owlswell()