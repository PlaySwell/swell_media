module SwellMedia
	class CategoryPolicy < ApplicationPolicy
		
		def admin?
			user.admin?
		end

		def admin_create?
			user.admin?
		end

		def admin_destroy?
			user.admin?
		end

		def admin_edit?
			user.admin?
		end

		def admin_empty_trash?
			user.admin?
		end

		def admin_update?
			user.admin?
		end
	end
end