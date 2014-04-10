module SwellMedia


	class Product < Media

		# after_create	:add_videos

		has_many :rewards

		def self.youtube_map
			# Amazon search indexes
			return {
					'Amazon Instant Video' => [ 'Movies', 'Shows'],
					'Appliances' => [ 'Science & Technology', 'Howto & Style' ],
					'Apps for Android' => [ 'Entertainment' ],
					'Arts, Crafts & Sewing' => [ 'Howto & Style' ],
					'Art and Craft Supply' => [ 'Howto & Style' ],
					'Automotive' => [ 'Autos & Vehicles' ],
					'Baby' => [ 'Howto & Style' ],
					'Beauty' => [ 'Howto & Style' ],
					'Books' => [ 'Education', 'Entertainment'],
					'Book' => [ 'Education', 'Entertainment'],
					'Cell Phones & Accessories' => [ 'Science & Technology' ],
					'Clothing & Accessories' => [ 'Howto & Style' ],
					'Collectibles & Fine Art' => [ 'Howto & Style' ],
					'Computers' => [ 'Science & Technology' ],
					'Credit Cards' => [ 'Howto & Style' ],
					'Digital Music Album' => [ 'Music' ],
					'Digital Music Track' => [ 'Music' ],
					'DVD' => [ 'Movies', 'Shows'],
					'Electronics' => [ 'Science & Technology' ],
					'Gift Cards Store' => [ 'Howto & Style' ],
					'Grocery' => [ 'Howto & Style' ],
					'Grocery & Gourmet Food' => [ 'Howto & Style' ],
					'Health & Personal Care' => [ 'Howto & Style' ],
					'Home & Kitchen' => [ 'Howto & Style' ],
					'Home Improvement' => [ 'Howto & Style' ],
					'Home Theater' => [ 'Science & Technology' ],
					'Industrial & Scientific' => [ 'Science & Technology' ],
					'Jewelry' => [ 'Howto & Style' ],
					'Kindle Store' => [ 'Science & Technology' ],
					'Magazine Subscriptions' => [ 'Entertainment', 'Education'],
					'Major Appliances' => [ 'Science & Technology', 'Howto & Style' ],
					'Mobile Application' => [ 'Science & Technology', 'Gaming' ],
					'Movies & TV' => [ 'Movies', 'Shows'],
					'MP3 Music' => [ 'Music' ],
					'Music' => [ 'Music' ],
					'Musical Instruments' => [ 'Music' ],
					'Office Products' => [ 'Howto & Style' ],
					'Patio, Lawn & Garden' => [ 'Howto & Style' ],
					'Personal Computer' => [ 'Science & Technology' ],
					'Pet Supplies' => [ 'Pets & Animals' ],
					'Photography' => [ 'Howto & Style' ],
					'Shoes' => [ 'Howto & Style' ],
					'Software' => [ 'Science & Technology' ],
					'Sports & Outdoors' => [ 'Sports' ],
					'Tools & Home Improvement' => [ 'Howto & Style' ],
					'Toys & Games' => [ 'Gaming' ],
					'Toy' => [ 'Gaming' ],
					'Video Games' => [ 'Gaming' ],
					'Watches' => [ 'Howto & Style' ],
					'Wireless' => [ 'Science & Technology' ],
					'Wine' => [ 'Howto & Style' ],
			}
		end

		def self.categories
			# Amazon search indexes
			return [ 'Apparel', 'ArtsAndCrafts', 'Books', 'DigitalMusic', 'Electronics', 'HealthPersonalCare', 'DVD', 'Music', 'Jewelry', 'KindleStore', 'Kitchen', 'MobileApps', 'Video', 'VideoGames', 'MP3Downloads', 'MusicalInstruments', 'Software', 'SportingGoods', 'Toys' ]
		end


		def self.new_from_amazon( args={} )

			asin = args[:asin] || args[:amazon_id] || args[:amzn_id] || args[:id]
			index = args[:index] || 'All'

			result = Amazon::Ecs.item_search( asin, :response_group => 'Medium', search_index: index ).items.first

			if result.nil?
				prod = Product.new
				prod.errors.add( :base, "Couldn't find product for asin #{asin}" )
				return prod
			end

			cat_name = result.get( 'ItemAttributes/ProductGroup' )
			if Product.youtube_map[result.get( 'ItemAttributes/ProductGroup' )].nil?
				puts "ERROR > Doesn't exist: #{result.get( 'ItemAttributes/ProductGroup' )}!!!!!!!!!!!!!!!!!!!"
			else
				cat_name = Product.youtube_map[result.get( 'ItemAttributes/ProductGroup' )].first
			end

			cat = Category.where( name: cat_name ).first
			if cat.nil?
				cat = Category.create( name: cat_name )
			end

			prod = Product.new(
						origin_identifier: 		result.get( 'ASIN' ),
						media_origin_id: 		MediaOrigin.find_by( slug: 'amazon' ).id,
						sub_type: 				result.get( 'ItemAttributes/ProductGroup' ),
						title: 					result.get( 'ItemAttributes/Title' ),
						user_id: 				args[:user_id],
						organization_id: 		args[:organization_id],
						description: 			HTMLEntities.new.decode( result.get( 'EditorialReviews/EditorialReview/Content' ) ),
						origin_url: 			result.get( 'DetailPageURL' ),
						category_id: 			cat.id,
						price:                  result.get( 'OfferSummary/LowestNewPrice/Amount' )
					)

			prod.properties = {
				author_name:  					result.get( 'ItemAttributes/Author' ) || result.get( 'ItemAttributes/Creator' ),
				published_at: 					result.get( 'ItemAttributes/ReleaseDate' ),
			}

			prod.media_thumbnails.build(
				name: 'medium', url: result.get_hash( 'SmallImage' )['URL'],
				height: result.get_hash( 'SmallImage' )['Height'],
				width: result.get_hash( 'SmallImage' )['Width']
			)

			prod.media_thumbnails.build(
				name: 'medium', url: result.get_hash( 'MediumImage' )['URL'],
				height: result.get_hash( 'MediumImage' )['Height'],
				width: result.get_hash( 'MediumImage' )['Width']
			)

			prod.media_thumbnails.build(
				name: 'medium', url: result.get_hash( 'LargeImage' )['URL'],
				height: result.get_hash( 'LargeImage' )['Height'],
				width: result.get_hash( 'LargeImage' )['Width']
			)

			prod.avatar = result.get_hash( 'LargeImage' )['URL']

			prod.title = prod.title + " - " + prod.author if prod.author.present?

			prod.organization_id = args[:organization_id] if args[:organization_id].present?

			return prod

		end


		def fetch_videos( args={} )
			num = args[:num] || 5
			delay = args[:delay]

			res = YouTubeIt::Client.new.videos_by( query: "#{self.author} #{self.title}" ).videos
			res[0..num-1].each do |vid|
				next if vid.nil?
				video = Video.find_by( origin_identifier: vid.unique_id ) || Video.new_from_youtube( yt_id: vid.unique_id )
				if video.save
					video.move_to_child_of( self )
				end
				sleep( delay ) if delay.present?
			end
		end


		private

			def add_videos

			end


	end

end