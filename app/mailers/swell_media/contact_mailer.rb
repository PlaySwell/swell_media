module SwellMedia
	class ContactMailer < ActionMailer::Base
		def new_contact( contact )
			@contact = contact
			mail to: 'gk@gkparishphilp.com', from: 'test@gk.com', subject: "#{SwellMedia.app_name} has a new contact!"
		end
	end
end