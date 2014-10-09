
#= require medium-editor
#= require ./medium-editor-insert-plugin.all
#= require ./MediumButton




jQuery.fn.mediumEditorInput = (args) ->
	args = {} if args == undefined
	selector = $(this)
	selector.each ->
		$textarea = $(this)
		$textarea.addClass('medium-editor-textarea')
		$textarea.after('<div class="medium-editor-input" style="outline: none;min-height:200px;" ></div>')
		$editable = $($textarea.next()[0])
		content = $($textarea.val())
		$editable.html( if content.is('.medium-editor-content') then content.html() else $textarea.val() )
		args = $editable.data("medium-editor-input") or { cleanPastedHTML: true, buttonLabels: 'fontawesome', buttons: ['bold', 'italic', 'underline', 'anchor', 'header1', 'header2', 'quote'] }

		args.extensions = {
		#'extension': new Extension()
		}

		editor = new MediumEditor($editable, args)

		$textarea.parents('form').first().on 'submit', ->
			$textarea.val "<div class='medium-editor-content'>#{editor.serialize()['element-0'].value}</div>"

		$editable.on "input", ->
			$textarea.val "<div class='medium-editor-content'>#{editor.serialize()['element-0'].value}</div>"

		if args['image-upload-script'] || $textarea.data('image-upload-script')
			$editable.mediumInsert
				editor: editor
				beginning: true,
				addons:
					images: {
						useDragAndDrop: false,
						imagesUploadScript: args['image-upload-script'] || $textarea.data('image-upload-script')
					}

#Extension = ->
#	this.parent = true;
#
#	this.button = document.createElement('button');
#	this.button.className = 'medium-editor-action';
#	this.button.innerText = 'X';
#	this.button.onclick = this.onClick.bind(this);
#
#	this
#
#Extension.prototype.getButton = ->
#	return this.button;
#
#Extension.prototype.onClick = ->
#	alert('This is editor: #' + this.base.id)