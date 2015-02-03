module SwellMedia
	
	class Contact < ActiveRecord::Base
		self.table_name = 'contacts'

		enum status: { 'draft' => 0, 'active' => 1, 'replied' => 2, 'archive' => 3, 'trash' => 4 }

		validates_format_of	:email, with: Devise.email_regexp, if: :email_changed?

		def to_s
			"#{self.contact_type || 'contact'} from #{self.email}"
		end
		
	end
end