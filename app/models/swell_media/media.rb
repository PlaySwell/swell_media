module SwellMedia

	class Media < ActiveRecord::Base
		self.table_name = 'media'

		include SwellMedia::Concerns::URLConcern
		mounted_at '/'

		enum status: { 'draft' => 0, 'active' => 1, 'archive' => 2, 'trash' => 3 }
		enum availability: { 'anyone' => 1, 'logged_in_users' => 2, 'just_me' => 3 }

		before_save	:set_publish_at, :set_keywords_and_tags , :set_cached_counts

		validates		:title, presence: true, unless: :allow_blank_title?

		attr_accessor	:slug_pref

		belongs_to	:user, class_name: SwellMedia.registered_user_class
		belongs_to 	:managed_by, class_name: 'User'
		belongs_to 	:category

		has_many	:assets, as: :parent_obj, dependent: :destroy

		include FriendlyId
		friendly_id :slugger, use: [ :slugged, :history ]

		acts_as_nested_set

		acts_as_taggable


		def self.published( args = {} )
			where( "media.publish_at <= :now", now: Time.zone.now ).active.anyone
		end


		# Instance Methods


		def author
			if self.properties.present?
				return self.properties['author_name']
			elsif self.user.present?
				return self.user.to_s
			else
				return ''
			end
		end

		def avatar_asset_file=( file )
			return false unless file.present?
			asset = ImageAsset.new(use: 'avatar', asset_type: 'image', status: 'active')
			asset.uploader = file
			asset.save
			asset.parent_obj = self
			assets << asset
			self.avatar = asset.try(:url)
		end

		def avatar_asset_url
			nil
		end

		def avatar_asset_url=( url )
			return false unless url.present?
			asset = ImageAsset.initialize_from_url(url, use: 'avatar', asset_type: 'image', status: 'active')
			unless asset.nil?
				asset.save

				asset.parent_obj = self
				assets << asset
			end
			puts "avatar_asset_url= asset: #{asset}"
			self.avatar = asset.try(:url) || url
		end

		def char_count
			return 0 if self.content.blank?
			self.sanitized_content.size
		end

		def page_meta
			if self.title.present?
				title = "#{self.title} | #{SwellMedia.app_name}"
			else
				title = SwellMedia.app_name
			end

			return {
				title: title,
				description: self.sanitized_description,
				image: self.avatar,
				url: self.url,
				twitter_format: 'summary_large_image',
				fb_type: 'article'
			}
		end

		def path( args={} )
			path = "/#{self.slug}"

			if args.present? && args.delete_if{ |k, v| k.blank? || v.blank? }
				path += '?' unless args.empty?
				path += args.map{ |k,v| "#{k}=#{v}"}.join( '&' )
			end
			return path
		end

		def sanitized_content
			ActionView::Base.full_sanitizer.sanitize( self.content )
		end

		def sanitized_description
			ActionView::Base.full_sanitizer.sanitize( self.description )
		end

		def should_generate_new_friendly_id?
			self.slug.nil? || self.slug_pref.present?
		end

		def slugger
			if self.slug_pref.present? 
				self.slug = nil # friendly_id 5.0 only updates slug if slug field is nil
				return self.slug_pref
			else
				return self.title
			end
		end

		def to_s
			self.title.present? ? self.title : self.slug
		end

		def word_count
			return 0 if self.content.blank?
			self.sanitized_content.scan(/[\w-]+/).size
		end


		private

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
					hashtags = self.sanitized_content.scan( /#\w+/ ).flatten.each{ |tag| tag[0]='' } 
					self.tag_list << hashtags
				end

				self.keywords = "#{self.author} #{self.title}".downcase.split( /\W/ ).delete_if{ |elem| elem.length <= 2 }.delete_if{ |elem| common_terms.include?( elem ) }.uniq
				self.tag_list.each{ |tag| self.keywords << tag.to_s }

			end

			def allow_blank_title?
				self.slug_pref.present?
			end
				

	end

end