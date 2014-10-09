module SwellMedia

	class Page < SwellMedia::Media

		def self.homepage
			self.find_by_slug( 'homepage' )
		end

		def plain_slug?
			true
		end

		def static_slug?
			true
		end
		
	end

end