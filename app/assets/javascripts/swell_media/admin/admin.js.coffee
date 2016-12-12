
ready = $ ->
	
	$('.editor-full').summernote
		height: 400

	$('.editor-small').summernote
		toolbar: [ ['style', ['bold', 'italic', 'underline', 'clear']] ]

	imageUploadToS3 = JSON.parse $('#asset-upload-json').text()
	imageUploadToS3['callback'] = (url, key) ->
		#The URL and Key returned from Amazon.
		console.log url
		console.log key

	$('textarea.wysiwyg').each ->
		$this = $(this)
		$this.froalaEditor({
			heightMin: $this.data('heightmin'),
			linkInsertButtons: ['linkBack'],
			linkList: false,
			codeBeautifier: true,
			linkMultipleStyles: false,
			toolbarInline: false,
			pastePlain: true,
			charCounterCount: false,
			placeholderText: $this.attr('placeholder'),
			height: $this.data('height'),
			toolbarSticky: true,
			imageUploadToS3: imageUploadToS3,
		})
	$('textarea.wysiwyg-inline').each ->
		$this = $(this)
		$this.froalaEditor({
			heightMin: $this.data('heightmin'),
			linkInsertButtons: ['linkBack'],
			linkList: false,
			codeBeautifier: true,
			linkMultipleStyles: false,
			toolbarInline: true,
			pastePlain: true,
			charCounterCount: false,
			toolbarButtons: ['bold', 'italic', 'underline', 'strikeThrough', 'color', 'emoticons', '-', 'paragraphFormat', 'align', 'formatOL', 'formatUL', 'indent', 'outdent', '-', 'insertImage', 'insertLink', 'insertFile', 'insertVideo', 'undo', 'redo']
			height: $this.data('height'),
			placeholderText: $this.attr('placeholder'),
			#toolbarSticky: false,
			imageUploadToS3: imageUploadToS3,
		})

	# $('.medium-editor').mediumEditorInput()

	$('.datepicker').datetimepicker
		dateFormat: 'dd MM, yy'


	if not not $('#article_category_id').val()
		$('#article_category_name').hide()

	$('#article_category_id').change ->
		if not not $(@).val()
			$('#article_category_name').hide()
		else
			$('#article_category_name').show()