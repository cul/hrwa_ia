module InternetArchive
  class ResponseAdapter

    @base_url = "https://archive-it.org/collections/1068"
    @metadata_fields =
      ['meta_Creator', 'meta_Coverage','meta_Subject', 'meta_Language',
       'meta_Collector', 'meta_Title']
    @date_fields = ['firstCapture','lastCapture']
    @linkable_fields = {'meta_Title' => 'allURL', 'url' => "allURL", 'numCaptures' => "allURL",
                        'numVideos' => "seedVideosUrl"}


    def self.adapt_response response_body
      response_body_string = response_body.to_s
      response_body_string.gsub!("$high%", "<span class='highlight'>")
      response_body_string.gsub!("/$light%", "</span>")
      res_data_json = JSON.parse(response_body_string)
      entities = res_data_json['results']['entities']
      processed_entities = process_entities(entities, res_data_json['results']["searchedFacets"])

      response_docs = { "response" => { "docs" => processed_entities } }
      response_docs.merge!('facet_counts' => { 'facet_queries'=>{},
                                               'facet_fields' => reformat_facets(res_data_json),'facet_dates'=>{} })
      response_docs["response"]["numFound"] = res_data_json['results']['totalResultCount']
      return response_docs
    end



    def self.process_entities(entities, searched_facets)
      entities_clone = entities.clone
      entities.each { |g|
        if !g["isSeed"]
          next
        end

        g_index = entities.index(g)
        g_clone = g.clone
        g.each do |ent, entval|
          if(ent == 'metadata')
            @metadata_fields.each { |k|
              if(entval[k])
                g_clone[k] = entval[k].map(&:html_safe)
                g_clone["linked_#{k}"] = link_faceted_results_data(k, entval[k], searched_facets)
              end
            }
          end

          #this field is not under the metadata node and not handled by process_entities
          websiteGroup = Array.new
          websiteGroup << g['websiteGroup']
          g_clone["linked_websiteGroup"] = link_faceted_results_data("websiteGroup", websiteGroup, searched_facets)

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

    def self.link_faceted_results_data(metadata_field, metadata_val, searched_facets)
      link_facet_arr = Array.new
      metadata_val.each { |mv|
        searched_facets.each { |sf|
          if(sf["id"] == metadata_field)
            sf['results'].each { |ra|
              if(ra['name'] == mv)
                link_facet_arr << make_link(ra['name'], convert_ia_facet_url(ra['addFacetURL']))
              end
            }
          end
        }
      }

      return link_facet_arr.map(&:html_safe)
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

    def self.convert_ia_facet_url(ia_facet_url)
      ia_facet_url.tr!('?', '')
      new_url_arr = Array.new
      facet_url_arr = Array.new

      ifu_hash = CGI.parse(ia_facet_url)
      ifu_hash.each do |k, v|
        if(k == 'fc')
          v.each { |v_fc|
            facet_url_arr << convert_ia_facet_url_param(v_fc)
          }
        else
          new_url_arr << "#{k}=#{v[0]}"
        end
      end
      new_url = ""

      new_url_arr.each { |param_string|
        if new_url == ""
          new_url = "#{param_string}&"
        else
          new_url="#{new_url}&#{param_string}&"
        end
      }

      facet_url_arr.each {|fps|
        new_url = "#{new_url}#{fps}&"
      }
      "?#{new_url.chomp('&')}"
    end

    def self.convert_ia_facet_url_param(value)
      ifu_arr = value.split(':')
      "f[#{ifu_arr[0]}][]=#{ifu_arr[1]}"
    end

  end
end
