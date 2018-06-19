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
                           "linked_numCaptures" => "https://wayback.archive-it.org/1068/*/http://www.mahteso.org/" } }

    # let(:linkable_fields) { {'url' => "", 'numCaptures' => "", 'firstCapture_date' => "",
    #     'lastCapture_date' => "", 'numVideos' => "", 'meta_Subject' => "",'websiteGroup' => "",
    #     'meta_Creator' => "", 'meta_Language' => "", 'meta_Coverage' => "", 'meta_Collector' => ""} }


    it 'should add anchor tags to linkable fields' do
      linked_fields.each do  |field, url_value|
        expect(result["response"]["docs"][0][field]).to include(url_value)
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

    it 'should convert hightlight to span tag' do
      expect(result["response"]["docs"][0]["meta_Title"][0]).to eq(display_title)
    end

    it 'should contain a facet_counts node' do
      expect(result["facet_counts"]).not_to be_empty
    end


  end


end
