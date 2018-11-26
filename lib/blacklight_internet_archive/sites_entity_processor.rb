require 'active_support/core_ext/string/output_safety'
require 'cgi'
require_relative 'entity_processor'

module BlacklightInternetArchive
  # extract and convert individual results from response

  class SitesEntityProcessor < EntityProcessor

    @metadata_fields
    @linkable_fields

    def initialize

      @metadata_fields = %w[meta_Creator meta_Coverage meta_Subject meta_Language meta_Collector meta_Title]
      @linkable_fields = {  'meta_Title' => 'allURL', 'url' => 'allURL', 'numCaptures' => 'allURL',
                            'numVideos' => 'seedVideosUrl' }
    end

    def run(response_json, base_url)
      raise ArgumentError 'No entities in response.' unless response_json['results']['entities']
      raise ArgumentError 'Base url required.' unless base_url

      entities = response_json['results']['entities']
      entities_clone = entities.clone
      entities.each do |entity|
        next unless entity['isSeed']
        entities_clone[entities.index(entity)] = reformat_entity(entity, response_json['results']['searchedFacets'], base_url)
      end
      entities_clone
    end


    def reformat_entity(entity, searched_facets, base_url)
      entity_clone = entity.clone
      entity.each do |entity_key, entity_val|
        if entity_key == 'metadata'
          entity_clone = facet_link_metadata(entity_val, entity_clone, searched_facets)
        end
        entity_clone = set_linked_fields(entity_clone, base_url)
      end
      # these fields are not under the metadata node and not handled by process_entities
      entity_clone['linked_websiteGroup'] = link_faceted_results_data('websiteGroup', [entity['websiteGroup']], searched_facets)
      val_url = entity_clone['allURL']
      val_url = "#{base_url}#{val_url}" if val_url.start_with?('?')
      entity_clone['linked_Captures'] = linked_val = make_link('View Site Captures on Wayback.org', val_url)
      entity_clone
    end

    def facet_link_metadata(entval, ent_clone, facet_info)
      @metadata_fields.each do |k|
        if entval[k]
          ent_clone[k] = entval[k].map(&:html_safe)
          ent_clone["linked_#{k}"] = link_faceted_results_data(k, entval[k], facet_info)
        end
      end
      ent_clone
    end

    def set_linked_fields(e_clone, base_url)
      @linkable_fields.each do |l, l_url|
        val = e_clone[l]
        val_url = e_clone[l_url]
        val_url = "#{base_url}#{val_url}" if val_url.start_with?('?')
        linked_val = make_link(val, val_url)
        e_clone["linked_#{l}"] = linked_val
      end
      e_clone
    end

    def link_faceted_results_data(meta_field, meta_val, searched_facets)
      link_facets = []
      meta_val.each do |mv|
        searched_facets.each do |sf|
          next unless sf['id'] == meta_field
          sf['results'].each do |ra|
            if ra['name'] == mv
              link_facets << make_link(ra['name'], convert_ia_facet_url(ra['addFacetURL']))
            end
          end
        end
      end
      link_facets.map(&:html_safe)
    end

    # translate ia facet url into blacklight facet syntax
    def convert_ia_facet_url(ia_facet_url)
      ifu_hash = CGI.parse(ia_facet_url.tr('?', ''))
      url_arrays = prepare_url_params(ifu_hash, [], [])
      compose_url(url_arrays)
    end

    def prepare_url_params(facet_hash, facet_url_arr, new_url_arr)
      facet_hash.each do |k, v|
        if k == 'fc'
          v.each do |v_fc|
            facet_url_arr << convert_ia_facet_url_param(v_fc)
          end
        else
          new_url_arr << "#{k}=#{v[0]}"
        end
      end
      [new_url_arr, facet_url_arr]
    end

    def compose_url(url_arrays)
      new_url = ''
      url_arrays[0].each do |param_string|
        new_url = if new_url == ''
          "#{param_string}&"
        else
          "#{new_url}&#{param_string}&"
        end
      end
      url_arrays[1].each do |fps|
        new_url = "#{new_url}#{fps}&"
      end
      "?#{new_url.chomp('&')}"
    end

    def convert_ia_facet_url_param(value)
      ifu_arr = value.split(':')
      "f[#{ifu_arr[0]}][]=#{ifu_arr[1]}"
    end

    def make_link(value, url)
      "<a href=\"#{url}\">#{value}</a>".html_safe
    end

  end
end
