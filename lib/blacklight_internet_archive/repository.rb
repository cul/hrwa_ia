# frozen_string_literal: true

require 'blacklight'

module BlacklightInternetArchive
  class Repository < Blacklight::AbstractRepository
    ##
    # Find a single document result by a known id
    # @param [String] id document's unique key value
    # @param [Hash] params additional query parameters
    def find(id, params = {})
      # response = send_and_receive id, params
      # raise Blacklight::Exceptions::RecordNotFound if response.documents.empty?
      # response
    end

    ##
    # Execute a search query against a search index
    # @param [Hash] params query parameters
    def search(builder)
      send_and_receive connection_config[:url], builder.blacklight_params
    end

    def send_and_receive(path, search_params = {})
      res = connection.execute_query(path, search_params)
      blacklight_config.response_model.new(res, search_params)
    end

    def build_connection
      BlacklightInternetArchive.connect(connection_config)
    end
  end
end
