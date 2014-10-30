
#= require medium-editor
#= require ./medium-editor-insert-plugin.all
#= require ./SwellMediumButton

youtubeUrlRegex = /(\?v=|\&v=|\/\d\/|\/embed\/|\/v\/|\.be\/)([a-zA-Z0-9\-\_]+)/;

jQuery.fn.selectText = ->
	doc = document
	element = this[0]
	if doc.body.createTextRange
		range = document.body.createTextRange()
		range.moveToElementText element
		range.select()
	else if window.getSelection
		selection = window.getSelection()
		range = document.createRange()
		range.selectNodeContents element
		selection.removeAllRanges()
		selection.addRange range
	return


jQuery.fn.mediumEditorInput = (args) ->
	args = {} if args == undefined
	selector = $(this)
	selector.each ->
		$textarea = $(this)
		$textarea.addClass('medium-editor-textarea')
		$textarea.after('<div class="medium-editor-input" style="outline: none;min-height:200px;" ></div>')
		$editable = $($textarea.next()[0])
		content = $('<div></div>').html($textarea.val())
		$editable.html( if content.children().first().is('.medium-editor-content') then content.children().first().html() else $textarea.val() )
		args = $editable.data("medium-editor-input") or { cleanPastedHTML: true, buttonLabels: 'fontawesome', buttons: ['bold', 'italic', 'underline', 'anchor', 'header1', 'header2', 'quote', 'embedMedia'] }

		args.extensions = {
			'embedMedia':  new SwellMediumButton(
				label:'Embed Media',
				className: 'medium-editor-action-embed-media',
				action: (html,mark)->
					url = html;

					youtubeRegexResults = url.match(youtubeUrlRegex);
					if youtubeRegexResults
						"<div class='iframe youtube'><iframe src='//www.youtube.com/embed/"+youtubeRegexResults[2]+"?wmode=opaque&modestbranding=1&rel=0&loop=1&hd=1&vq=large&autoplay=0' style='width:100%;' frameborder='0' allowfullscreen='1'></iframe></div><p><br/></p>"
					else
						html

			)
			'checkstate':  new SwellMediumButton(
				label: 'checkstate',
				action: ()->,
				checkState: (node)->

					$('button', this.base.toolbarActions).show()

					html = getCurrentSelection()
					if html.match(/^http(s)?:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=\w+)(?:\S+)?$/)
						$('button:not(.medium-editor-action-embed-media)', this.base.toolbarActions).hide()
					else
						$('button.medium-editor-action-embed-media', this.base.toolbarActions).hide()


			)
		}

		editor = new MediumEditor($editable, args)

		$textarea.parents('form').first().on 'submit', ->
			$textarea.val "<div class='medium-editor-content'>#{editor.serialize()['element-0'].value}</div>"

		getSelectionStart = () ->
			node = document.getSelection().anchorNode
			(if node && node.nodeType == 3 then node.parentNode else node);

		$editable.on "paste",  (e) ->
			e.preventDefault()
			$(getSelectionStart()).selectText() if getSelectionStart() && $(getSelectionStart()).html().match(youtubeUrlRegex)
			false

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