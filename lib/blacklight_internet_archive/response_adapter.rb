require 'json'

module BlacklightInternetArchive
  class ResponseAdapter
    def self.adapt_response(response_body, base_url)
      response_body_string = convert_highlighting(response_body.to_s)
      res_data_json = JSON.parse(response_body_string)
      response_docs = { 'response' => { 'docs' => EntityProcessor.run(res_data_json, base_url) } }
      response_docs.merge!('facet_counts' => { 'facet_queries' => {},
                                               'facet_fields' => reformat_facets(res_data_json), 'facet_dates' => {} })
      set_paging_stats(response_docs, res_data_json)
      response_docs
    end

    def self.convert_highlighting(response_string)
      response_string.gsub!('$high%', "<span class='highlight'>")
      response_string.gsub!('/$light%', '</span>')
      response_string
    end

    def self.set_paging_stats(response_docs, res_data_json)
      response_docs['response']['numFound'] = res_data_json['results']['totalResultCount']
      response_docs['response']['page'] = res_data_json['pageParams']['page']
      response_docs['response']['rows'] = res_data_json['pageParams']['pageSize']
      response_docs
    end

    def self.reformat_facets(response_json)
      facets_hash = {}
      facets = response_json['results']['searchedFacets']
      facets.each do |f|
        key_name = f['id']
        facets_hash[key_name] = reformat_item(f['results'])
      end
      facets_hash
    end

    def self.reformat_item(item_arr)
      new_item_arr = []
      item_arr.each do |item_hash|
        new_item_arr << item_hash['name']
        new_item_arr << item_hash['count']
      end
      new_item_arr
    end
  end
end
