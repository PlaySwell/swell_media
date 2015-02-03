module SwellMedia
	class ContactPolicy < ApplicationPolicy
		
		def admin?
			user.admin?
		end

		def admin_create?
			true
		end

		def admin_destroy?
			user.admin?
		end

		def admin_edit?
			user.admin?
		end

		def admin_update?
			user.admin?
		end
	end
end