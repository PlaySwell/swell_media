module SwellMedia
	
	class Contact < ActiveRecord::Base
		self.table_name = 'contacts'


		def to_s
			"#{self.contact_type || 'contact'} from #{self.email}"
		end
		
	end
end