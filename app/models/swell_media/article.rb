
module SwellMedia

	class Article < SwellMedia::Media

		attr_accessor	:category_name

		before_save 	:set_cached_word_count

		def category_name=( name )
			self.category = SwellMedia::Category.where( name: name ).first_or_create
		end

		def reading_time( args={} )
			wpm = args[:wpm] || 225

			estimated_time = self.word_count / wpm.to_f

			return { minutes_only: estimated_time.round, minutes: estimated_time.to_i, seconds: ( ( estimated_time % 1 ) * 60 ).round }

		end

		def word_count
			return 0 if self.content.blank?
			ActionView::Base.full_sanitizer.sanitize( self.content ).scan(/[\w-]+/).size
		end


		private

			def set_cached_word_count
				if self.respond_to?( :cached_word_count )
					self.cached_word_count = self.word_count
				end
			end
	end

end