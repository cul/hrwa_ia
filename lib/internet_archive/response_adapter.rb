module InternetArchive
  class ResponseAdapter  	

      @base_url = "https://archive-it.org/collections/1068"
      @metadata_fields =
        ['meta_Creator', 'meta_Coverage','meta_Subject', 'meta_Language',
         'meta_Collector', 'meta_Title']
      @date_fields = ['firstCapture','lastCapture']
      @linkable_fields = {'url' => "allURL", 'numCaptures' => "allURL", 'numVideos' => "seedVideosUrl"}
      # @linkable_fields = {'url' => "allURL", 'numCaptures' => "",
      #   'numVideos' => "", 'meta_Subject' => "",'websiteGroup' => "",
      #   'meta_Creator' => "", 'meta_Language' => "", 'meta_Coverage' => "", 'meta_Collector' => ""}


    def self.adapt_response response_body
      response_body_string = response_body.to_s
      response_body_string.gsub!("$high%", "<span class='highlight'>")
      response_body_string.gsub!("/$light%", "</span>")
      res_data_json = JSON.parse(response_body_string)
      # puts res_data_json['results']["searchedFacets"]
      # puts res_data_json['results']["searchedFacets"][0]['id']
      # puts res_data_json['results']["searchedFacets"][0]['results'][0]['addFacetURL']

      entities = res_data_json['results']['entities']
      processed_entities = process_entities(entities)
      response_docs = { "response" => { "docs" => processed_entities } }
      response_docs.merge!('facet_counts' => { 'facet_queries'=>{},
                                               'facet_fields' => reformat_facets(res_data_json),'facet_dates'=>{} })
      response_docs["response"]["numFound"] = res_data_json['results']['totalResultCount']
      return response_docs
    end



    def self.process_entities(entities)
      entities_clone = entities.clone
      entities.each { |g|
        g_index = entities.index(g)
        g_clone = g.clone
        g.each do |ent, entval|
          if(ent == 'metadata')
            @metadata_fields.each { |k|
              if(entval[k])
                g_clone[k] = entval[k].map(&:html_safe)
              end
            }
          end
          @date_fields.each { |d|
            if(ent == d)
              new_key = "#{d}_date"
              if(entval["formattedDate"])
                formattedDate = entval["formattedDate"]
                dateUrl = entval["waybackUrl"]
                date_link = make_link(formattedDate, dateUrl)
                g_clone[new_key] = formattedDate
                g_clone["linked_#{new_key}"] = date_link.html_safe
              end
            end
          }
        end
        @linkable_fields.each do |l, l_url|
          val = g_clone[l]
          val_url = g_clone[l_url]
          if(val_url.starts_with?('?'))
            val_url= "#{@base_url}#{val_url}"
          end
          linked_val = make_link(val, val_url)
          g_clone["linked_#{l}"] = linked_val
        end
        entities_clone[g_index] = g_clone
      }
      entities_clone
    end

    def self.reformat_facets(response_json)
      facets_hash = {}
      facets = response_json["results"]["searchedFacets"]
      facets.each { |f|
        key_name = f["id"]
        facets_hash[key_name] = reformat_item(f["results"])
      }
      return facets_hash
    end

    def self.create_facet_links
      # facets_hash = {}
      # facets = response_json["results"]["searchedFacets"]
      # facets.each { |f|
      #   key_name = f["id"]
      #   facets_hash[key_name] = reformat_item(f["results"])
      # }
    end

    def self.reformat_item item_arr
      new_item_arr = []
      item_arr.each { |item_hash|
        new_item_arr << item_hash['name']
        new_item_arr <<  item_hash['count']
      }
      new_item_arr
    end

    def self.make_link(value, url)
      "<a href=\"#{url}\">#{value}</a>".html_safe
    end




  end
end
