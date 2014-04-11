module SwellMedia

	class Category < ActiveRecord::Base

		before_save :set_label

		belongs_to	:moderator, class_name: 'User'

		has_many	:media

		acts_as_nested_set

		include FriendlyId
		friendly_id :name, use: :slugged


		def to_s
			self.label
		end

		private

			def set_label
				self.label ||= self.name.capitalize
			end

	end

end