module SwellMedia
	class ContactAdminController < ApplicationController
		before_filter :authenticate_user!
		before_filter :get_contact, except: [ :create, :empty_trash, :export, :import, :index ]
		layout 'admin'

		def destroy
			authorize( Contact, :admin_destroy? )
			@contact.destroy
			set_flash "#{@contact.to_s} from #{@contact.email} Deleted"
			redirect_to contact_admin_index_path
		end


		def edit
			authorize( Contact, :admin_edit? )
		end

		def export
			authorize( Contact, :admin? )

			@contacts = Contact.all

			if params[:status].present? && params[:status] != 'all'
				@contacts = eval "@contacts.#{params[:status]}"
			end

			if params[:type].present? && params[:type] != 'all'
				@contacts = @contacts.where( type: params[:type] )
			end

			if params[:q].present?
				@contacts = @contacts.where( "email like :q", q: "'%#{params[:q].downcase}'%" )
			end

			respond_to do |format|
				format.csv { render text: @contacts.to_csv }
			end
		end


		def import
			if count = Contact.import_from_csv( params[:file] )
				set_flash "#{count} contacts imported"
				redirect_to contact_admin_index_path
			else
				set_flash 'Could Not Import.', :error
				redirect_to :back
			end
		end


		def index
			authorize( Contact, :admin? )
			
			sort_by = params[:sort_by] || 'created_at'
			sort_dir = params[:sort_dir] || 'desc'

			@contacts = Contact.order( "#{sort_by} #{sort_dir}" )

			if params[:status].present? && params[:status] != 'all'
				@contacts = eval "@contacts.#{params[:status]}"
			end

			if params[:type].present? && params[:type] != 'all'
				@contacts = @contacts.where( type: params[:type] )
			end

			if params[:q].present?
				@contacts = @contacts.where( "email like :q", q: "'%#{params[:q].downcase}'%" )
			end

			@contact_count = @contacts.size

			@contacts = @contacts.page( params[:page] )
		end


		def update
			authorize( Contact, :admin_update? )

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