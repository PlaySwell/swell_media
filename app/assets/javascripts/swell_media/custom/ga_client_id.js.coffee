$(document).ready ->
	if window['ga']
		ga((tracker) ->
			clientId = tracker.get('clientId');

			$('.ga-client-id').val(clientId);

			$('[href*="ga_client_id=%3Aga_client_id"],[href*="ga_client_id=:ga_client_id"]').each ->
				$(this).attr('href', $(this).attr('href').replace("ga_client_id=%3Aga_client_id","ga_client_id="+clientId))

			meta_ga = $('meta[property="ga:client_id"]')
			meta_user_events = $('meta[property="user_events"]')

			if meta_ga.length == 1 && !meta_ga.attr('content') && meta_user_events.attr('content')

				$.post( meta_user_events.attr('content'), { ga_client_id: clientId, event: 'ga_init' } )

				meta_ga.attr( 'content', clientId )

		);