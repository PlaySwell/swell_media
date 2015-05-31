module SwellMedia
	class UserPolicy < ApplicationPolicy
		
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

	end
end