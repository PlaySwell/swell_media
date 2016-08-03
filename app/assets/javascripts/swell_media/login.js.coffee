#= require ./plugins/jquery.bind-first-0.2.3

$(document).ready ->


	$(document).onFirst(
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




	$(document).on(
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

	$(document).on(
		'click',
		'a.auth-pop',
	(e) ->
		popupCenter($(this).attr("href"), $(this).attr("data-width") || 600, $(this).attr("data-height") || 400, "authPopup");
		e.stopPropagation(); return false;
	);

	set_ga_client_id = null
	set_ga_client_id = (interval)->
		if window.ga && window.ga['getAll']
			try
				client_id = ga.getAll()[0].get('clientId');

				if client_id
					$('meta[property="ga:client_id"]').attr('content', client_id)

					exp_date = new Date()
					exp_date.setTime(exp_date.getTime() + 2592000000) # now + 30 days

					document.cookie = 'ga_client_id='+client_id+'; expires='+exp_date.toGMTString()+'; path=/'
					console.log 'client_id', client_id if window.console
					return true
			catch error
				console.log error if window.console

		# try 10 times before giving up
		if interval < 10
			setTimeout(
				()->
					set_ga_client_id(interval+1)
			, 1000
			)

	set_ga_client_id(1)

