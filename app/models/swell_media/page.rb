module SwellMedia

	class Page < SwellMedia::Media

		def self.homepage
			self.find_by_slug( 'homepage' )
		end
		
	end

end