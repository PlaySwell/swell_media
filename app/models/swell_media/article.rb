
module SwellMedia

	class Article < SwellMedia::Media

		attr_accessor	:category_name

		def category_name=( name )
			self.category = SwellMedia::Category.where( name: name ).first_or_create
		end

		def reading_time( args={} )
			wpm = args[:wpm] || 225

			estimated_time = self.word_count / wpm.to_f

			return { minutes_only: estimated_time.round, minutes: estimated_time.to_i, seconds: ( ( estimated_time % 1 ) * 60 ).round }

		end

	end

end