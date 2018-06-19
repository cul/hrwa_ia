# frozen_string_literal: true
require 'net/http'

module InternetArchive
  class Client


    def initialize connection_url, options = {}
      @connection_url = connection_url
      @options = options
    end

    # +execute_query+ is the main request method responsible for sending requests to the +connection+ object.
    #
    # "path" : A string value that represents the repository request handler (set url value in blacklight.yml)
    # "opts" : A hash containing searh parameters

    def execute_query path, opts
      request_context = build_request path, opts
      execute request_context
    end

    #
    def execute request_context
      uri = URI(URI.encode(request_context[:params][:uri]))

      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        res_data = res.read_body
        return if res_data.nil? || res_data.empty?
        res_data_mod = InternetArchive::ResponseAdapter.adapt_response(res_data)
        bl = InternetArchive::HashWithResponse.new(request_context,  res, res_data_mod)
      end

    end


    # +build_request+ accepts a path and options hash
    # +build_request+ sets up the uri/query string
    # returns a hash with the following keys:
    #   :uri
    #   :path
    #   :query
    def build_request path, opts
      raise "path must be a string or symbol, not #{path.inspect}" unless [String,Symbol].include?(path.class)
      path = path.to_s
      opts[:path] = path

      query_opts = {}
      query_opts['q'] = opts['q']
      #To do: remove RSolr dependency
      query = RSolr::Uri.params_to_solr(query_opts)
      opts[:query] = query
      opts[:uri] = path.to_s + (query ? "?#{query}" : "")

      opts[:rows] = 10 if opts[:rows].nil?

      opts[:start] = 0 if opts[:start].nil?

      request_opts = { :params => opts }
    end

  end
end
