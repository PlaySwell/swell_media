module SwellMedia

	class Category < ActiveRecord::Base
		self.table_name = 'categories'

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		
		has_many	:media

		acts_as_nested_set

		include FriendlyId
		friendly_id :name, use: :slugged

		

		def to_s
			self.display
		end

	end

end