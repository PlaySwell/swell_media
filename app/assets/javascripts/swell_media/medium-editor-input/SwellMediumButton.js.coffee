#= require ./MediumButton

class SwellMediumButton extends MediumButton
	constructor: (options)->
		options.swellMediumButton = this
		super(options)
		this.button.classList.add(options['className']) if options['className']
		this.parent = true
		console.log 'SwellMediumButton', this

	checkState: (node) ->
		if this.options['checkState']
			this.options['checkState'].call(this,node)

		super(node)

window.SwellMediumButton = SwellMediumButton
