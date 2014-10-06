module SwellMedia
	class ContactsController < ApplicationController
		
		skip_before_filter :verify_authenticity_token, :only => [ :create ]

		before_filter :authenticate_user!, only: [ :admin, :edit, :update, :destroy ]

		def admin
			authorize! :admin, Contact
			@contacts = Contact.order( 'created_at desc' )

			render layout: 'admin'
		end


		def create
			@contact = Contact.new( contact_params )

			if @contact.save
				
				SwellMedia::ContactMailer.new_contact( @contact ).deliver

				if ENV['MAILCHIMP_DEFAULT_LIST_ID'].present? && ( params[:optin].present? || @contact.contact_type == 'optin' )
					mail_api = Gibbon::API.new
					mail_api.lists.subscribe( { id: ENV['MAILCHIMP_DEFAULT_LIST_ID'], email: { email: email }, double_optin: true } )
				end

				set_flash 'Thanks!'
				redirect_to '/'
			else
				set_flash 'There was a problem...', :danger, @contact
				redirect_to :back
			end
		end

		def destroy
			@contact = Contact.find( params[:id] )
			@contact.destroy
			set_flash "#{@contact.contact_type || 'contact'} from #{@contact.email} Deleted"
			redirect_to admin_contacts_path
		end

		def edit
			@contact = Contact.find( params[:id] )
			render layout: 'admin'
		end


		def new
			@contact = Contact.new	
			set_page_meta title: 'Contact'
		end


		private

			def contact_params
				if params[:contact].present?
					params.require( :contact ).permit( :email, :subject, :message, :contact_type )
				else
					return { email: params[:email], subject: params[:subject], message: params[:message], contact_type: params[:contact_type] }
				end
			end
	end
end