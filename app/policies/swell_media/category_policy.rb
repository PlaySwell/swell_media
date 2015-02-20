module SwellMedia
	class CategoryPolicy < ApplicationPolicy

		def index?
			user.admin?
		end

		def admin?
			user.admin?
		end

		def create?
			user.admin?
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