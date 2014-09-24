class ArticlePolicy < ApplicationPolicy
	def update?
		user.admin? or post.author == user
	end
end