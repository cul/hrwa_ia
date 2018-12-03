require 'active_support/core_ext/string/output_safety'
require 'cgi'
require_relative 'sites_entity_processor'

module BlacklightInternetArchive
  # extract and convert individual results from response
  class EntityProcessor

  	def self.get_processor(search_type = 'catalog')
  		if search_type == 'search_pages'
  			# return ArchivedPagesEntityProcessor.new
  		elsif search_type == 'search_videos'
        # return SeedVideosEntityProcessor.new
      else 
        return SitesEntityProcessor.new
      end
  	end


    def run(response_json, base_url)
        raise NotImplementedError
    end
  end
end
