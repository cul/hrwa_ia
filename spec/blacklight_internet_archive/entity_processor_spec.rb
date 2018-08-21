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

    it 'returns a hash' do
      expect(described_class.run(response_json, base_url)).to be_a Hash
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
end
