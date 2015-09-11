module SwellMedia
	class RegistrationsController < Devise::RegistrationsController
		
		layout 'sessions'

		
		def check_name
			if User.find_by( name: params[:name] )
				render text: "#{params[:name]} has been taken"
			else
				render text: "ok"
			end
		end

		
		def create
			email = params[:user][:email]
			# todo -- check validity of email param?

			user_class = SwellMedia.registered_user_class.constantize

			user = user_class.where( email: email ).first

			unless user.try(:unregistered?)
				# this email is already registered for this site
				set_flash "#{email} is already registered.", :error
				redirect_to :back
				return false

			end

			user ||= user_class.new( email: email, status: (SwellMedia.default_user_status || 'pending') )

			user.status = SwellMedia.default_user_status || 'pending' if user.unregistered?

			user.name = params[:user][:name]
			user.ip = request.ip
			user.password = params[:user][:password]
			user.password_confirmation = params[:user][:password_confirmation]

			if user.save
				record_user_event( event: 'registration', user: user, obj: user, content: 'Registration successful' )

				if user.active_for_authentication?

					set_flash "Thanks for signing up!"
					sign_up( :user, user )

					path = after_sign_up_path_for( user )

					redirect_to path

				else

					set_flash "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account." if user.inactive_message == :unconfirmed
					expire_data_after_sign_in!
					redirect_to after_inactive_sign_up_path_for(user)

				end
			else
				set_flash "Could not register user.", :error, user
				render :new
				return false
			end

		end

		protected
		def after_inactive_sign_up_path_for(resource)
			'/'
		end

	end
end