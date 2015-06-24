
module SwellMedia
	class ConfirmationsController < Devise::ConfirmationsController

		layout 'sessions'

		protected

		# The path used after resending confirmation instructions.
		def after_resending_confirmation_instructions_path_for(resource_name)
			'/'
		end

		# The path used after confirmation.
		def after_confirmation_path_for(resource_name, resource)
			'/'
		end

	end
end