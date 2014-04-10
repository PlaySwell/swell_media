
module SwellMedia

	class Video < Media

		validates_uniqueness_of	:origin_identifier

		def self.new_from_api( args={} )

			api_id = args['media'] || args[:api_id]
			vid = MediaApi.campaign(api_id)
			return false if vid.nil?

			unless vid['category_name'].nil?
				cat = Category.where( name: vid['category_name'] ).first
				if cat.nil?
					cat = Category.create( name: vid['category_name'] )
				end
			end

			video = Video.new(
					origin_identifier: 				vid['campaign_uuid'],
					media_origin_id: 				MediaOrigin.find_by( slug: 'api' ).id,
					title: 							vid['title'],
					sub_type: 						'web_video',
					#duration: 						vid.duration,
					description: 					vid['description'],
					#category_id: 					cat.id,
					#keywords: 						vid.keywords,
					content: 						vid['url']
			)

			video.category_id = cat.id unless cat.nil?

			video.properties = {
					#published_at: 				vid['created_at'],
					#uploaded_at: 				vid['created_at'],
					#author_name: 				vid.author.name,
					#author_uri: 				vid.author.uri,
					#rating_count: 				vid.rating.try( :rater_count ),
					#rating_avg: 				vid.rating.try( :average ),
					#like_count: 				vid.rating.try( :likes ),
					#dislike_count: 				vid.rating.try( :dislikes ),
					#view_count: 				vid['total_views'],
					#favorite_count: 			vid.favorite_count,
					#comment_count: 				vid.comment_count,
					#latitude: 					vid.latitude,
					#longitude: 					vid.longitude,
			}


			video.user_id = args[:user_id] if args[:user_id].present?

			video.media_thumbnails.build( name: 'thumb', url: vid['offer_image'], height: 0, width: 0 )

			video.avatar = vid['offer_image']

			return video

		end


		def self.new_from_playwire( args={} )

			pw_id = args[:pw_id] || args[:playwire_id] || args[:playwire_video_id] || args[:id] || args['id']

			vid = Playwire::video( pw_id )
			return false if vid.nil?

			cat = Category.where( name: vid['category_name'] ).first
			if cat.nil?
				cat = Category.create( name: vid['category_name'] )
			end

			video = Video.new(
					origin_identifier: 				vid['id'],
					media_origin_id: 				MediaOrigin.find_by( slug: 'playwire' ).id,
					title: 							vid['name'],
					sub_type: 						'web_video',
					#duration: 						vid.duration,
					#description: 					vid.description,
					category_id: 					cat.id,
					#keywords: 						vid.keywords,
					content: 						vid['iframe_embed_code']
			)

			video.properties = {
					published_at: 				vid['created_at'],
					uploaded_at: 				vid['created_at'],
					#author_name: 				vid.author.name,
					#author_uri: 				vid.author.uri,
					#rating_count: 				vid.rating.try( :rater_count ),
					#rating_avg: 				vid.rating.try( :average ),
					#like_count: 				vid.rating.try( :likes ),
					#dislike_count: 				vid.rating.try( :dislikes ),
					view_count: 				vid['total_views'],
					#favorite_count: 			vid.favorite_count,
					#comment_count: 				vid.comment_count,
					#latitude: 					vid.latitude,
					#longitude: 					vid.longitude,
			}


			video.user_id = args[:user_id] if args[:user_id].present?

			video.media_thumbnails.build( name: 'thumb', url: vid['thumb_url'], height: 0, width: 0 )

			video.avatar = vid['thumb_url']

			return video

		end


		def self.new_from_youtube( args={} )

			yt_id = args[:yt_id] || args[:youtube_id] || args[:youtube_video_id] || args[:id]

			vid = YouTubeIt::Client.new.video_by( yt_id )
			return false if vid.nil?

			cat = Category.where( name: vid.categories.first.term ).first
			if cat.nil?
				cat = Category.create( name: vid.categories.first.term )
			end

			video = Video.new(
				origin_identifier: 				vid.unique_id,
				media_origin_id: 				MediaOrigin.find_by( slug: 'youtube' ).id,
				title: 							vid.title,
				sub_type: 						'web_video',
				duration: 						vid.duration,
				description: 					vid.description,
				category_id: 					cat.id,
				keywords: 						vid.keywords,
				content: 						vid.embed_html5
			)

			video.properties = {
					published_at: 				vid.try( :published_at ),
					uploaded_at: 				vid.try( :uploaded_at ),
					author_name: 				vid.author.name,
					author_uri: 				vid.author.uri,
					rating_count: 				vid.rating.try( :rater_count ),
					rating_avg: 				vid.rating.try( :average ),
					like_count: 				vid.rating.try( :likes ),
					dislike_count: 				vid.rating.try( :dislikes ),
					view_count: 				vid.try( :view_count ),
					favorite_count: 			vid.try( :favorite_count ),
					comment_count: 				vid.try( :comment_count ),
					latitude: 					vid.try( :latitude ),
					longitude: 					vid.try( :longitude ),
			}


			video.user_id = args[:user_id] if args[:user_id].present?

			vid.thumbnails.each do |thumb|
				video.media_thumbnails.build( name: thumb.try( :name ), url: thumb.url, height: thumb.height, width: thumb.width )
			end

			video.avatar = video.media_thumbnails.sort{ |a,b| b.width <=> a.width }.first.try( :url )

			return video

		end


		def formatted_duration
			Time.at( self.duration.to_i ).utc.strftime( "%M:%S" )
		end

	end

end