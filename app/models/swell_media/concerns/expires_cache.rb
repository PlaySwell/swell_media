module SwellMedia
	module Concerns

		module ExpiresCache
			extend ActiveSupport::Concern

			included do
				before_save do |model|
					# are there any changed fields which expire the cache?
					if ( model.changed & (model.class.config_expiring_fields || []) ).present?
						model.modified_at = Time.now
					end
				end
			end


			####################################################
			# Class Methods

			module ClassMethods

				def expires_cache( *fields )
					if fields.count == 1 && fields.first.is_a?( Array )
						@expiring_fields = fields.first
					else
						@expiring_fields = (fields || []).collect{ |f| f.to_s }
					end
				end


				def expires_cache_append( *fields )
					super_expiring_fields = []
					super_expiring_fields = self.superclass.config_expiring_fields if self.superclass.present?

					if fields.count == 1 && fields.first.is_a?( Array )
						@expiring_fields = super_expiring_fields + fields.first
					else
						@expiring_fields = super_expiring_fields + (fields || []).collect{ |f| f.to_s }
					end
				end

				def config_expiring_fields
					if @expiring_fields.present?
						@expiring_fields
					elsif self.superclass.present?
						self.superclass.config_expiring_fields
					end
				end

			end

			def cache_key
				"ExpiresCache/#{self.class.name}/#{self.id}/#{(self.modified_at || self.updated_at).strftime('%Y%m%d%H%M%S%L')}"
			end


		end
	end
end