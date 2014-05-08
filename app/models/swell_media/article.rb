
module SwellMedia

	class Article < SwellMedia::Media

		attr_accessor	:category_name

		def category_name=( name )
			self.category = SwellMedia::Category.where( name: name ).first_or_create
		end

	end

end