module SwellMedia

	class UserPost < Media
		# parent class for user content.... comments, discussions, etc...

		validate 		:parent_obj_is_commentable

		belongs_to 		:parent_obj, polymorphic: true
		belongs_to		:user

		has_many 		:votes, as: :votable, dependent: :destroy

		### Plugins --------------------------------------------------
		acts_as_nested_set

		include FriendlyId
		friendly_id :title, use: :slugged




		def self.active
			where( status: 'active' )
		end




		def active?
			self.status == 'active'
		end


		def to_s
			"a post by #{self.user}"
		end


		def url
			self.parent_obj.url + '#discussion_post_' + self.id.to_s
		end


		private

			def parent_obj_is_commentable
				if self.parent_obj.present? && not( self.parent_obj.is_commentable? )
					self.errors.add :base, "Comments are closed."
					return false
				end
			end
	end

end