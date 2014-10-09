module SwellMedia

	class Media < ActiveRecord::Base
		self.table_name = 'media'

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		enum availability: { 'anyone' => 0, 'logged_in_users' => 1, 'just_me' => 2 }

		before_save	:set_publish_at, :set_keywords_and_tags , :set_cached_counts

		after_save :reslug
		after_create {
			@created = true
			reslug
			@created = false
		}

		validates		:title, presence: true, unless: :allow_blank_title

		attr_accessor	:slug_pref

		belongs_to	:user
		belongs_to 	:managed_by, class_name: 'User'
		belongs_to 	:category

		has_many	:assets, as: :parent_obj, dependent: :destroy

		include FriendlyId
		friendly_id :slugger, use: :slugged

		acts_as_nested_set

		acts_as_taggable

		def self.id_from_slug( slug )
			return nil if slug.nil?
			hashid = slug.split('-').last
			puts "id_from_slug #{slug}, #{hashid}, #{SwellMedia::HASHIDS.decrypt(hashid).first}"
			SwellMedia::HASHIDS.decrypt(hashid).first
		end

		def self.find(*args)
			id = args.first
			return super if args.count != 1 || Media.id_from_slug(id).nil?
			super(Media.id_from_slug(id))
		end

		def self.published
			where( 'publish_at <= :now', now: Time.zone.now ).active.anyone
		end



		def author
			if self.properties.present?
				return self.properties['author_name']
			elsif self.user.present?
				return self.user.to_s
			else
				return ''
			end
		end

		def char_count
			return 0 if self.content.blank?
			ActionView::Base.full_sanitizer.sanitize( self.content ).size
		end

		def path( args={} )
			path = "/#{self.slug}"

			if args.present? && args.delete_if{ |k, v| k.blank? || v.blank? }
				path += '?' unless args.empty?
				path += args.map{ |k,v| "#{k}=#{v}"}.join( '&' )
			end
			return path
		end

		def slugger

			the_slug = self.slug_pref.present? ? self.slug_pref : self.title

			if self.id && !self.plain_slug?
				if the_slug.blank?
					the_slug = SwellMedia::HASHIDS.encrypt(self.id)
				else
					the_slug = "#{the_slug} #{SwellMedia::HASHIDS.encrypt(self.id)}"
				end
			end

			the_slug
		end

		def plain_slug?
			!ENV['SLUGS_INCLUDE_HASHID']
		end

		def static_slug?
			!ENV['SLUGS_UPDATE']
		end

		def to_s
			self.title
		end

		def url( args={} )
			domain = ( args.present? && args.delete( :domain ) ) || ENV['APP_DOMAIN'] || 'localhost:3000'
			protocol = ( args.present? && args.delete( :protocol ) ) || 'http'
			path = self.path( args )
			url = "#{protocol}://#{domain}#{self.path( args )}"

			return url

		end

		def word_count
			return 0 if self.content.blank?
			ActionView::Base.full_sanitizer.sanitize( self.content ).scan(/[\w-]+/).size
		end


		private

			def reslug
				if !@reslugged && ( !self.static_slug? || (@created && !self.plain_slug?) )
					self.slug = nil
					@reslugged = true
					self.save!
					@reslugged = false
				end
			end

			def set_cached_counts
				if self.respond_to?( :cached_word_count )
					self.cached_word_count = self.word_count
				end

				if self.respond_to?( :cached_char_count )
					self.cached_char_count = self.char_count
				end
			end

			def set_publish_at
				# set publish_at
				self.publish_at ||= Time.zone.now
			end

			def set_keywords_and_tags
				common_terms = ["able", "about", "above", "across", "after", "almost", "also", "among", "around", "back", "because", "been", "below", "came", "cannot", "come", "cool", "could", "dear", "does", "down", "each", "either", "else", "ever", "every", "find", "first", "from", "from", "gave", "give", "goodhave", "have", "hers", "however", "inside", "into", "its", "just", "least", "like", "likely", "little", "live", "long", "made", "make", "many", "might", "more", "most", "must", "neither", "number", "often", "only", "other", "our", "outside", "over", "part", "people", "place", "rather", "said", "says", "should", "show", "side", "since", "some", "sound", "take", "than", "that", "the", "their", "them",  "then", "there", "these", "they", "thing", "this", "those", "time", "twas", "under", "upon", "was", "wants", "were", "what", "whatever", "when", "where", "which", "while", "whom", "will", "with", "within", "work", "would", "write", "year", "you", "your"]
				
				# auto-tag hashtags
				unless self.content.blank?
					hashtags = self.content.scan( /#\w+/ ).flatten.each{ |tag| tag[0]='' } 
					self.tag_list << hashtags
				end

				self.keywords = "#{self.author} #{self.title}".downcase.split( /\W/ ).delete_if{ |elem| elem.length <= 2 }.delete_if{ |elem| common_terms.include?( elem ) }.uniq
				self.tag_list.each{ |tag| self.keywords << tag.to_s }

				

			end

			def allow_blank_title
				false
			end
				


	end

end