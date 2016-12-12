
$.fn.present = ()->
	selector = $(this)
	selector.length > 0

$.fn.try = ()->
	selector = $(this)

	f = arguments[0]
	args = []
	for i in [1...arguments.length]
		#console.log i, i-1, arguments[i]
		args[i-1] = arguments[i]
	#args = ([0...10] )

	if selector.present()
		#console.log f, args
		selector[f].apply( selector, args )