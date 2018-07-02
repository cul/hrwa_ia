require 'rails_helper'

describe InternetArchive::ResponseAdapter do


  let(:response_adapter) do
    InternetArchive::ResponseAdapter
  end


  context "adapt_response" do

    let (:display_title) { "Mwatikho <span class='highlight'>Torture</span> Survivors Organization" }
    let(:ia_json) { IO.read(Rails.root.join("spec", "fixtures", "mwatikho.json")) }
    let (:result) { response_adapter.adapt_response(ia_json) }
    let(:linked_fields) { {"linked_url" => "https://wayback.archive-it.org/1068/*/http://www.mahteso.org/",
                           "linked_numCaptures" => "https://wayback.archive-it.org/1068/*/http://www.mahteso.org/",
                           "linked_firstCapture_date" => "https://wayback.archive-it.org/1068/19000101000000/http://www.mahteso.org/",
                           "linked_numVideos" => "https://archive-it.org/collections/1068?q=http%3A%2F%2Fwww.mahteso.org%2F&show=SeedVideos&fc=seedId%3A1159185",
                           "linked_meta_Coverage" => "?q=mwatikho&f[meta_Coverage][]=Kenya"
                           } }
    let (:metadata_field) { "websiteGroup" }
    let (:metadata_val) { ["Non-governmental organizations"] }
    let (:searched_facets) { [{"numResults"=>1, "results"=>[{"count"=>1, "addFacetURL"=>"q=mwatikho&fc=meta_Coverage%3AKenya&fc=websiteGroup%3ANon-governmental+organizations", "constrained"=>false, "name"=>"Non-governmental organizations"}], "hasMore"=>false, "toggleAlphaURL"=>"?q=mwatikho&fc=meta_Coverage%3AKenya&falpha=f_websiteGroup%3Afalse", "alpha"=>true, "id"=>"websiteGroup"}] }
    let (:url) { "<a href=\"?q=mwatikho&f[meta_Coverage][]=Kenya&f[websiteGroup][]=Non-governmental organizations\">Non-governmental organizations</a>" }


    it 'should add links to linkable fields' do
      linked_fields.each do  |field, url_value|
        f = result["response"]["docs"][0][field]
        if f.kind_of?(Array)
          f = f[0]
        end
        expect(f).to include(url_value)
      end
    end

    it 'should make results the root node' do
      expect(result["response"]).not_to be_empty
    end

    it 'should make docs an array' do
      expect(result["response"]["docs"]).to be_an Array
    end

    it 'should return return a numFound value that converts to an Integer' do
      expect { Integer(result["response"]["numFound"]) }.to_not raise_error
    end

    it 'should convert highlight to span tag' do
      expect(result["response"]["docs"][0]["meta_Title"][0]).to eq(display_title)
    end

    it 'should contain a facet_counts node' do
      expect(result["facet_counts"]).not_to be_empty
    end

    it 'should track already selected facets with each request' do
      arr = response_adapter.link_faceted_results_data(metadata_field, metadata_val, searched_facets)
      expect(arr[0]).to eq(url)
    end


  end


end
