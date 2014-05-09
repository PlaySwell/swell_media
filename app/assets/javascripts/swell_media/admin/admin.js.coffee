
ready = $ ->
	
	$('.editor-full').summernote
		height: 400

	$('.editor-small').summernote
		toolbar: [ ['style', ['bold', 'italic', 'underline', 'clear']] ]

	$('.datepicker').datetimepicker
		dateFormat: 'dd MM, yy'


	$('#article_category_id').change ->
		if not not $(@).val()
			$('#article_category_name').hide()
		else
			$('#article_category_name').show()