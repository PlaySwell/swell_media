module SwellMedia
	class ContactMailer < ActionMailer::Base
		def new_contact( contact )
			@contact = contact
			mail to: SwellMedia.contact_email_to, from: SwellMedia.contact_email_from, subject: "#{SwellMedia.app_name} has a new contact!"
		end
	end
end