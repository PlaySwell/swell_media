#= require ./jquery.fileupload
#= require ./jquery.iframe-transport

assetup_counter = 0;

jQuery.assetdirect = (args) ->
	args = {} if args == undefined

	#window.console and console.log 'assetdirect', args

	if args['progressBar']
		$(args['progressBar']).removeClass('_'+per+'-per') for per in [0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100]
		$(args['progressBar']).removeClass('_complete')

	$form = $('<form enctype="multipart/form-data" id="file_upload" method="post"><input name="file" type="file"></form>')
	$form.fileupload
		autoUpload: true
		method: 'POST'
		action: ''
		add: (event, data) ->
			$.ajax
				dataType: 'json'
				url: args['newUrl']
				cache: false
				success: (response) ->
					#console.log(JSON.stringify(response))
					data.url = response.action
					data.formData = response.request
					$form.data 'asset', response
					$form.fileupload 'send', data
					return
				error: (response, status) ->
					#window.console and console.log('there was an error')
					return
			return
		progress: (e, data) ->
			#Calculate the completion percentage of the upload
			progress = parseInt(data.loaded / data.total * 100, 10)
			#window.console and console.log('progress', progress, e, data, args['progressBar'], args)

			if args['progressOutput']
				$(args['progressOutput']).html (if progress >= 10 and progress < 10 then '&nbsp;' else '') + progress + '%'

			if args['progressBar']
				increment = Math.floor(progress / 5) * 5
				#window.console and console.log "increment", increment
				$(args['progressBar']).addClass('_'+increment+'-per')

			return
		send: (e, data) ->
			#window.console and console.log('send', e, data)
			return
		done: (e, data) ->
			#window.console and console.log('done', e, data, data.result)
			$result = $(data.result)
			request =
				dataType: 'json'
				url: $form.data('asset').callback.url
				method: 'GET'
				data: $.extend($form.data('asset').callback.data,
					key: $result.find('Key').text()
					bucket: $result.find('Bucket').text())
				success: (callback_response, textStatus, jqXHR) ->
					#window.console and console.log('callback success', callback_response, textStatus, jqXHR)

					if args['progressBar']
						$(args['progressBar']).addClass('_complete')

					if args['urlInput']
						$(args['urlInput']).val( callback_response['url'] ).change()
					if args['for']
						$(args['for']).val( callback_response['url'] ).change()
					if args['idInput']
						$(args['idInput']).val( callback_response['id'] ).change()
					if args['backgroundPreview']
						$(args['backgroundPreview']).css('background-image', 'url(\'' + callback_response['url'] + '\')').addClass( '_fileupload_preview' )
					if args['imgPreview']
						$(args['imgPreview']).css('src', 'url(\'' + callback_response['url'] + '\')').addClass '_fileupload_preview'
					if args['callback']
						args['callback']( callback_response )
					return
			#window.console and console.log(request)
			$.ajax request
			return
		fail: (e, data) ->
			#window.console and console.log('fail', e, data, data.result)
			return
		success: (e, data) ->
			#window.console and console.log('success', e, data, data.result)
			return
	$form.find('input').click()
	return



jQuery.fn.assetup = (args) ->
	args = {} if args == undefined

	$(this).each ()->


		$this = $(this)
		$for = $($this.data('for'))

		acceptFileTypes = args['accept-file-types'] || $this.data('accept-file-types') || /(\.|\/)(gif|jpe?g|png)$/i
		maxFileSize			= args['max-file-size'] || $this.data('max-file-size') || 5000000
		asset						= args['asset'] || $this.data('asset') || {}
		params					= args['params'] || $this.data('params') || {}
		params.asset = asset

		form_id = "new_asset_"+(assetup_counter++)

		$('body').append("""
		<form accept-charset="UTF-8" action="/assets?response=url&#{$.param(params)}" class="new_asset" enctype="multipart/form-data" id="#{form_id}" method="post" style="display:none;">
					<div style="display:none"><input name="utf8" type="hidden" value="✓"><!--<input name="authenticity_token" type="hidden" value="r/4R6o85mAPcpp6nFjya/v9VjI/0314YxgVxkYM2vPk=">--></div>
					<input name="file" type="file">
          <input name="commit" type="submit" value="Upload">
		</form>
""")

		$form = $('#'+form_id)

		$upload = $form.find('[type=file]')

		$form.fileupload(
			maxFileSize: maxFileSize,
			acceptFileTypes: acceptFileTypes,
			progress: (e, data) ->
				# Calculate the completion percentage of the upload
				progress = parseInt(data.loaded / data.total * 100, 10);
		#window.console and console.log progress, e, data if window.console
			done: (e, data) ->
				#window.console and console.log data.result if window.console
				$for.each ()->
					if $(this).is('img')
						$(this).attr('src',data.result)
					else
						$(this).val(data.result).change()
				$form.remove()

		)

		$upload.change = (e)->
			$form.submit()

		$upload.click()

$(document).ready ->

	$('body').on(
		'click'
		'[data-toggle=assetup]',
		(e)->
			e.preventDefault()
			$(this).assetup()
	)

	$('body').on(
		'click'
		'.asset-direct',
	(e)->
		e.preventDefault()
		e.stopPropagation()
		#window.console && console.log 'data', $(this).data()
		$.assetdirect( $.extend($(this).data()||{},{ newUrl: $(this).attr('href'), progressOutput: $('.progress_output',this), for: $(this).attr('for') }) )
	)