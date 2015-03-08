
$.user_event = ( event, data = {} )->

	url = $('meta[property="user_events"]').attr('content')

	data.ga_client_id = data.ga_client_id || $('meta[property="ga:client_id"]').attr('content')
	data.event = event

	if url
		$.post( url, data )
		if window.console
			console.log 'user_event', event, data
	else if window.console
		console.error 'Unable to post user event... there is no url'

	if window['ga']
		ga(
			'send'
			'event'
			data.group || data.parent_obj_type || 'Site Event' 	#category
			event,        												#action
			data.content, 												#label
			data.value   	 												#value
		)


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
			  $.user_event( 'ga_init', { ga_client_id: clientId } )

			meta_ga.attr( 'content', clientId )

		);

	$('body').on(
		'click'
		'a[data-user-event]',
		(event) ->
			$.user_event( $(this).data('user-event'), $(this).data('user-event-data') )
	)