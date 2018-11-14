# frozen_string_literal: true

require 'net/http'
require 'active_support/core_ext/hash'

module BlacklightInternetArchive
  class Client
    def initialize(connection_url, options = {})
      @connection_url = connection_url
      @options = options
    end

    # +execute_query+ is the main request method responsible for sending requests to the +connection+ object.
    #
    # "path" : A string value that represents the repository request handler (set url value in blacklight.yml)
    # "opts" : A hash containing searh parameters

    def execute_query(path, opts)
      request_context = build_request path, opts
      execute request_context
    end

    def execute(request_context)
      uri_string = request_context[:params][:uri]
      uri = URI.parse(uri_string)
      search_type = request_context[:params][:controller]

      res = Net::HTTP.get_response(uri)
      return unless res.is_a?(Net::HTTPSuccess)
      res_data = res.read_body
      return if res_data.nil? || res_data.empty?
      res_data_mod = BlacklightInternetArchive::ResponseAdapter.adapt_response(res_data, @connection_url, search_type)
      BlacklightInternetArchive::HashWithResponse.new(request_context, res, res_data_mod)
    end

    # +build_request+ accepts a path and options hash
    # +build_request+ sets up the uri/query string
    # returns a hash with the following keys:
    #   :uri
    #   :path
    #   :query
    #   :rows and :start


    def build_request(path, opts)
      raise "path must be a string or symbol, not #{path.inspect}" unless [String, Symbol].include?(path.class)
      opts[:path] = "#{path}.json"
      query_opts = construct_query_options(opts)
      opts[:start] = calculate_start(query_opts)
      facet_string = construct_facet_string(opts)
      query = query_opts.to_query
      query = "#{query}&#{facet_string}" if facet_string
      opts[:query] = query
      opts[:uri] = opts[:path].to_s + (query ? "?#{query}" : '')
      opts[:rows] = 10 if opts[:rows].nil?
      { params: opts }
    end

    def construct_query_options(opts)
      query_opts = {}
      query_opts['pageSize'] = '10'
      query_opts['pageSize'] = opts['rows'] if opts['rows']
      query_opts['page'] = '1'
      query_opts['page'] = opts['page'] if opts['page']
      query_opts['q'] = ''
      query_opts['q'] = CGI.escape(opts['q']) if opts['q']
      query_opts
    end

    def calculate_start(query_opts)
      start = 0
      if query_opts['page'].to_i >= 2
        start = ((query_opts['page'].to_i - 1) * query_opts['pageSize'].to_i)
      end
      start
    end

    def construct_facet_string(opts)
      facet_string = ''
      if opts['f']
        opts['f'].each do |k, v|
          v.each do |fv|
            fval = CGI.escape(fv)
            facet_string = "#{facet_string}fc=#{k}%3A#{fval}&"
          end
        end
      end
      facet_string = facet_string.tr(' ', '+').chomp('&')
    end
  end
end
