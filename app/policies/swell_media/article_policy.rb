module SwellMedia
	class ArticlePolicy < ApplicationPolicy
		
		def admin?
			user.admin?
		end

		def admin_create?
			user.admin?
		end

		def admin_destroy?
			user.admin? or record.author == user
		end

		def admin_edit?
			user.admin? or record.author == user
		end

		def admin_empty_trash?
			user.admin? 
		end

		def admin_preview?
			user.admin? or record.author == user
		end

		def admin_update?
			user.admin? or record.author == user
		end
	end
end