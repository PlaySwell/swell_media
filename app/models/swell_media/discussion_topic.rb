module SwellMedia

	class DiscussionTopic < Media

		has_many 	:discussion_posts, as: :parent_obj

		def to_s
			self.title
		end

		def url( args=nil )
			"/discussions/#{self.slug}"
		end

	end

end