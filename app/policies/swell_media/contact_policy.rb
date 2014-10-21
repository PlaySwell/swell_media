module SwellMedia
	class ContactPolicy < ApplicationPolicy
		
		def admin?
			user.admin?
		end

		def create?
			true
		end

		def destroy?
			user.admin?
		end

		def edit?
			user.admin?
		end

		def update?
			user.admin?
		end
	end
end