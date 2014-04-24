module SwellMedia

	class Category < ActiveRecord::Base
		self.table_name = 'categories'

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		
		before_save :set_display

		belongs_to	:moderator, class_name: 'User'

		has_many	:media

		acts_as_nested_set

		include FriendlyId
		friendly_id :name, use: :slugged


		def self.active
			where( status: :active )
		end


		

		def to_s
			self.label
		end

		private

			def set_display
				self.display ||= self.name.capitalize
			end

	end

end