require 'json'

describe BlacklightInternetArchive::EntityProcessor do
  before(:all) do
    @entity_json = JSON.parse(File.read("spec/fixtures/mwatikho.json"))
    @output_json = JSON.parse(File.read("spec/fixtures/output.json"))
    @entity = described_class.reformat_entity(@entity_json['results']['entities'][0], @entity_json['results']['searchedFacets'], 'base_url')
  end

  describe '.run' do
    let(:base_url) { '' }
    let(:response_json) { JSON.parse(File.read("spec/fixtures/mwatikho.json")) }

    it 'returns an array' do
      expect(described_class.run(response_json, base_url)).to be_an Array
    end

    it 'raises error if entities are not present' do
      expect { described_class.run({}, base_url) }.to raise_error StandardError
    end
  end

  describe '.reformat_entity' do
    it 'returns an entity with a linked_websiteGroup field' do
      expect(@entity['linked_websiteGroup']).not_to be_nil
    end
  end

  describe '.set_date_fields' do
    let(:date_field) { 'firstCapture' }
    let(:entity_value) { { "waybackUrl" => "https://wayback.archive-it.org/1068/19000101000000/http://www.mahteso.org/", "formattedDate" => "Jan 01, 1900", "date" => -2208988800000 } }
    let(:url) { '<a href="https://wayback.archive-it.org/1068/19000101000000/http://www.mahteso.org/">Jan 01, 1900</a>' }
    let(:date_key) { 'linked_firstCapture_date' }

    it 'constructs linked date field' do
      expect(described_class.set_date_fields(@entity, date_field, entity_value)[date_key]).to eq(url)
    end
  end

  describe '.link_faceted_results_data' do
    let(:metadata_field) { 'websiteGroup' }
    let(:metadata_val) { ['Non-governmental organizations'] }
    let(:searched_facets) {
      [
        { 'numResults' => 1, 'results' => [{ 'count' => 1, 'addFacetURL' => 'q=mwatikho&fc=meta_Coverage%3AKenya&fc=websiteGroup%3ANon-governmental+organizations', 'constrained' => false, 'name' => 'Non-governmental organizations' }], 'hasMore' => false, 'toggleAlphaURL' => '?q=mwatikho&fc=meta_Coverage%3AKenya&falpha=f_websiteGroup%3Afalse', 'alpha' => true, 'id' => 'websiteGroup' }
      ]
    }
    let(:f_pattern) { 'q=mwatikho&f[meta_Coverage][]=Kenya&f[websiteGroup][]=Non-governmental organizations' }


    it 'should track already selected facets with each request' do
      arr = described_class.link_faceted_results_data(metadata_field, metadata_val, searched_facets)
      expect(arr[0]).to include(f_pattern)
    end
  end

  describe '.convert_ia_facet_url' do
    let(:input_string) { 'q=world&fc=meta_Creator%3AMarkaz+%CA%BBAmm%C4%81n+li-Dir%C4%81s%C4%81t+%E1%B8%A4uq%C5%ABq+al-Ins%C4%81n&fc=meta_Subject%3AHuman+rights+advocacy&fc=websiteGroup%3ANon-governmental+organizations' }
    let(:output_string) { '?q=world&f[meta_Creator][]=Markaz ʻAmmān li-Dirāsāt Ḥuqūq al-Insān&f[meta_Subject][]=Human rights advocacy&f[websiteGroup][]=Non-governmental organizations' }

    it 'should convert ia facet url to blacklight format ' do
      expect(described_class.convert_ia_facet_url(input_string)).to eq(output_string)
    end
  end
end
