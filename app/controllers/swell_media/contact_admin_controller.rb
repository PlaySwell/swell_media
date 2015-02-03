module SwellMedia
	class ContactAdminController < ApplicationController
		before_filter :authenticate_user!
		before_filter :get_contact, except: [ :create, :empty_trash, :index ]
		layout 'admin'

		def destroy
			authorize( @contact, :admin_destroy? )
			@contact.destroy
			set_flash "#{@contact.contact_type || 'contact'} from #{@contact.email} Deleted"
			redirect_to admin_contact_index_path
		end


		def edit
			authorize( @contact, :admin_edit? )
		end


		def index
			authorize( Contact, :admin? )
			
			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@contacts = Contact.order( "#{sort_by} #{sort_dir}" )

			if params[:status].present? && params[:status] != 'all'
				@contacts = eval "@contacts.#{params[:status]}"
			end

			if params[:contact_type].present? && params[:contact_type] != 'all'
				@contacts = @contacts.where( contact_type: params[:contact_type] )
			end

			if params[:q].present?
				@contacts = @contacts.where( "email like :q", q: "'%#{params[:q].downcase}'%" )
			end

			@contacts = @contacts.page( params[:page] )
		end


		def update
			authorize( @contact, :admin_update? )

			@contact.update( contact_params )

			if @contact.save
				set_flash 'Contact Updated'
				redirect_to edit_contact_admin_path( id: @contact.id )
			else
				set_flash 'Contact could not be Updated', :error, @contact
				render :edit
			end
		end


		private

			def contact_params

				params.require( :contact ).permit( :status )

			end

			def get_contact
				@contact = Contact.find( params[:id] )
			end

	end
end