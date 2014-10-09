module SwellMedia
	class MediaPolicy < ApplicationPolicy
		
		def admin?
			user.admin?
		end

		def create?
			user.admin?
		end

		def destroy?
			user.admin? or record.author == user
		end

		def edit?
			user.admin? or record.author == user
		end

		def preview?
			user.admin? or record.author == user
		end

		def update?
			user.admin? or record.author == user
		end
	end
end