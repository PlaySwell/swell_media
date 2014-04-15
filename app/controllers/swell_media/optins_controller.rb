module SwellMedia
	class OptinsController < ApplicationController
		skip_before_filter :verify_authenticity_token, :only => [ :create ]

		def create

			email = params[:email]

			contact = Contact.where( email: email, contact_type: 'optin' ).first_or_initialize

			if contact.save
				#mail_api = Gibbon::API.new
				
				#list_id = mail_api.lists.list( list_name: 'Pre-Launch' )['data'].first['id']
				#mail_api.lists.subscribe( { id: '27437bba9b', email: { email: email }, double_optin: true } )

				ContactMailer.new_contact( contact ).deliver

				set_flash "Thanks for signing up!"
				redirect_to :back
			else
				set_flash "Hmmm,seems like there was problem with your email address.", :warning
				redirect_to :back
			end
			
		end
	end
end