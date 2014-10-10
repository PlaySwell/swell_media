#= require ./jquery.fileupload
#= require ./jquery.iframe-transport

assetup_counter = 0;

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
		<form accept-charset="UTF-8" action="/assets?response=url&#{$.param(params)}" class="new_asset" enctype="multipart/form-data" id="#{form_id}" method="post">
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
				console.log progress, e, data if window.console
			done: (e, data) ->
				console.log data.result if window.console
				$for.val(data.result).change()
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