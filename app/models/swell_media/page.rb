module SwellMedia

	class Page < SwellMedia::Media

		def self.homepage
			self.find_by_slug( 'homepage' )
		end



		def page_meta
			super.merge( fb_type: 'article' )
		end

		
	end

end