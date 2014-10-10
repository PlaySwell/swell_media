
jQuery.fn.inputfor = (args) ->
	args = {} if args == undefined

	$(this).each ()->
		$input = $(this)
		console.log( 'inputfor', $input ) if window.console
		$for = $($input.data('inputfor'))

		$input.on 'change keyup paste', ->
			console.log( 'inputfor', $input, 'change keyup paste' ) if window.console
			setTimeout( ->

					$for.each ()->
						$forItem = $(this)
						console.log( 'inputfor $forItem', $forItem ) if window.console
						if $forItem.is('img')
							$forItem.attr('src',$input.val())
						else
							$forItem.val($input.val()).change()
				, 5
			)

$(document).ready ->
	console.log( 'inputfor ready' ) if window.console
	$('[data-inputfor]').inputfor()