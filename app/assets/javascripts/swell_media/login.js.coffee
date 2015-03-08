#= require ./plugins/jquery.bind-first-0.2.3

$(document).ready ->


	$('body').onFirst(
		'click'
		'a[data-passthru!="false"]',
	(e)->
		if $(this).data('passthru') != undefined

			e.preventDefault()
			e.stopPropagation();
			e.stopImmediatePropagation()

			$('.modal.swell_media_login_modal').modal('show')

			$a = $(this)

			passthru = $a.data('passthru')

			window.load_location = (url)->

				$a.attr('data-passthru', 'false').data('passthru', 'false')

				if $a.data('toggle') == 'modal'
					setTimeout(
						()->
							$($a.data('target')).modal('toggle')
						, 5
					)
				else if ( $a.parents('.voter').length > 0 ) || passthru == 'click'
					$a.click()
					$('.swell_media_login_modal').modal('hide')
				else
					window.location = $a.attr('href')

			return false
	)




	$('body').on(
		'submit'
		'form[data-passthru!="false"]',
	(e)->
		unless $(this).data('passthru') == undefined
			e.preventDefault()
			e.stopPropagation();
			e.stopImmediatePropagation()

			$form = $(this)

			window.load_location = (url)->
				$('.swell_media_login_modal').modal('hide')
				$form.attr('data-passthru', 'false').data('passthru', 'false')
				$form.submit()

			$('.swell_media_login_modal').modal('show')
	)

	popupCenter = (url, width, height, name) ->
		left = (screen.width/2)-(width/2);
		top = (screen.height/2)-(height/2);
		return window.open(url, name, "menubar=no,toolbar=no,status=no,width="+width+",height="+height+",toolbar=no,left="+left+",top="+top);

	$('body').on(
		'click',
		'a.auth-pop',
	(e) ->
		popupCenter($(this).attr("href"), $(this).attr("data-width") || 600, $(this).attr("data-height") || 400, "authPopup");
		e.stopPropagation(); return false;
	);