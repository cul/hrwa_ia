# frozen_string_literal: true

require 'net/http'

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

      res = Net::HTTP.get_response(uri)
      if res.is_a?(Net::HTTPSuccess)
        res_data = res.read_body
        return if res_data.nil? || res_data.empty?
        res_data_mod = BlacklightInternetArchive::ResponseAdapter.adapt_response(res_data, @connection_url)
        BlacklightInternetArchive::HashWithResponse.new(request_context, res, res_data_mod)
      end
    end

    # +build_request+ accepts a path and options hash
    # +build_request+ sets up the uri/query string
    # returns a hash with the following keys:
    #   :uri
    #   :path
    #   :query

    def build_request(path, opts)
      raise "path must be a string or symbol, not #{path.inspect}" unless [String, Symbol].include?(path.class)
      path = "#{path}.json"

      opts[:path] = path
      query_opts = {}
      query_opts['pageSize'] = '10'
      if opts['rows']
        query_opts['pageSize'] = opts['rows']
      else
        query_opts['pageSize'] = '10'
      end
      if opts['page']
        query_opts['page'] = opts['page']
      else
        query_opts['page'] = '1'
      end
      if query_opts['page'].to_i < 2
        opts[:start] = 0
      else
        opts[:start] = ((query_opts['page'].to_i - 1) * query_opts['pageSize'].to_i)
      end

      query_opts['q'] = ''
      query_opts['q'] = CGI.escape(opts['q']) if opts['q']

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
      query = query_opts.to_query
      query = "#{query}&#{facet_string}" if facet_string

      opts[:query] = query
      opts[:uri] = path.to_s + (query ? "?#{query}" : '')

      opts[:rows] = 10 if opts[:rows].nil?

      opts[:start] = 0 if opts[:start].nil?

      { :params => opts }
    end
  end
end
