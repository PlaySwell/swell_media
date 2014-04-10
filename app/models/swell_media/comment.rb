module SwellMedia

	class Comment < Media

		has_one 		:point_investment

		belongs_to 		:parent_obj, polymorphic: true

		acts_as_nested_set

		def self.root
			active.where('parent_id IS NULL')
		end

		def active?
			self.status == 'active'
		end

		def title
			"a comment by #{self.user}"
		end

		def url( args = {} )
			self.parent_obj.url + '#comment_' + self.id.to_s
		end



	end

end