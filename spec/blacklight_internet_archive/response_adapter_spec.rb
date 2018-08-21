describe BlacklightInternetArchive::ResponseAdapter do
  let(:response_adapter) do
    BlacklightInternetArchive::ResponseAdapter
  end


  context 'adapt_response' do

    let(:ia_json) { File.read("spec/fixtures/mwatikho.json") }


    let(:result) { response_adapter.adapt_response(ia_json, 'https://wayback.archive-it.org/1068/') }
    let(:linked_fields) { { 'linked_url' => 'https://wayback.archive-it.org/1068/*/http://www.mahteso.org/',
                            'linked_numCaptures' => 'https://wayback.archive-it.org/1068/*/http://www.mahteso.org/',
                            'linked_firstCapture_date' => 'https://wayback.archive-it.org/1068/19000101000000/http://www.mahteso.org/',
                            'linked_numVideos' => 'https://archive-it.org/collections/1068?q=http%3A%2F%2Fwww.mahteso.org%2F&show=SeedVideos&fc=seedId%3A1159185',
                            'linked_meta_Coverage' => '?q=mwatikho&f[meta_Coverage][]=Kenya' } }
    let(:metadata_field) { 'websiteGroup' }
    let(:metadata_val) { ['Non-governmental organizations'] }
    let(:searched_facets) { [{ 'numResults' => 1, 'results' => [{ 'count' => 1, 'addFacetURL' => 'q=mwatikho&fc=meta_Coverage%3AKenya&fc=websiteGroup%3ANon-governmental+organizations', 'constrained' => false, 'name' => 'Non-governmental organizations' }], 'hasMore' => false, 'toggleAlphaURL' => '?q=mwatikho&fc=meta_Coverage%3AKenya&falpha=f_websiteGroup%3Afalse', 'alpha' => true, 'id' => 'websiteGroup' }] }
    let(:url) { '<a href=\'?q=mwatikho&f[meta_Coverage][]=Kenya&f[websiteGroup][]=Non-governmental organizations\'>Non-governmental organizations</a>' }
    let(:input_string) { 'q=world&fc=meta_Creator%3AMarkaz+%CA%BBAmm%C4%81n+li-Dir%C4%81s%C4%81t+%E1%B8%A4uq%C5%ABq+al-Ins%C4%81n&fc=meta_Subject%3AHuman+rights+advocacy&fc=websiteGroup%3ANon-governmental+organizations' }
    let(:output_string) { '?q=world&f[meta_Creator][]=Markaz ʻAmmān li-Dirāsāt Ḥuqūq al-Insān&f[meta_Subject][]=Human rights advocacy&f[websiteGroup][]=Non-governmental organizations' }

    it 'should add links to linkable fields' do
      linked_fields.each do |field, url_value|
        f = result['response']['docs'][0][field]
        f = f[0] if f.is_a?(Array)
        expect(f).to include(url_value)
      end
    end

    it 'should make results the root node' do
      expect(result['response']).not_to be_empty
    end

    it 'should make docs an array' do
      expect(result['response']['docs']).to be_an Array
    end

    it 'should return a numFound value that converts to an Integer' do
      expect { Integer(result['response']['numFound']) }.to_not raise_error
    end


    it 'should contain a facet_counts node' do
      expect(result['facet_counts']).not_to be_empty
    end

    it 'should track already selected facets with each request' do
      arr = response_adapter.link_faceted_results_data(metadata_field, metadata_val, searched_facets)
      expect(arr[0]).to eq(url)
    end

    it 'should convert ia facet url to blacklight format ' do
      expect(response_adapter.convert_ia_facet_url(input_string)).to eq(output_string)
    end
  end
end
