module SwellMedia
	class Tag < ActiveRecord::Base
		self.table_name = 'tags'

		has_many :taggings

	end
end