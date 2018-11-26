require_relative '../../lib/blacklight_internet_archive/response_adapter'

describe BlacklightInternetArchive::ResponseAdapter do
  describe '.adapt_response' do
    let(:ia_json) { File.read("spec/fixtures/mwatikho.json") }
    let(:result) { described_class.adapt_response(ia_json, 'https://wayback.archive-it.org/1068/') }
    let(:linked_fields) {
      { 'linked_url' => 'https://wayback.archive-it.org/1068/*/http://www.mahteso.org/',
        'linked_numCaptures' => 'https://wayback.archive-it.org/1068/*/http://www.mahteso.org/',
        'linked_firstCapture_date' => 'https://wayback.archive-it.org/1068/19000101000000/http://www.mahteso.org/',
        'linked_numVideos' => 'show=SeedVideos&fc=seedId%3A1159185',
        'linked_meta_Coverage' => 'f[meta_Coverage][]=Kenya' }
    }

    it 'adds links to linkable fields' do
      linked_fields.each do |field, url_value|
        f = result['response']['docs'][0][field]
        f = f[0] if f.is_a?(Array)
        expect(f).to include(url_value)
      end
    end

    it 'makes response the root node' do
      expect(result['response']).not_to be_empty
    end

    it 'makes docs an array' do
      expect(result['response']['docs']).to be_an Array
    end

    it 'contains a facet_counts node' do
      expect(result['facet_counts']).not_to be_empty
    end

    it 'returns a numFound value that converts to an Integer' do
      expect { Integer(result['response']['numFound']) }.not_to raise_error
    end
  end
end
