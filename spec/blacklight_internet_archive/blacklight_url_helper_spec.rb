describe BlacklightUrlHelper do

  let(:ia_doc) { YAML.load_file("spec/fixtures/mwatikho.json") }
  let(:ia_url) { ia_doc['results']['entities'][0]['allURL'] }
  let(:ia_context_href_url) { "#{ia_url}?counter=1" }
  let(:ia_opts) { { counter: '1' } }

  describe '.link_to_document' do
    it 'constructs an ia url' do
      expect(described_class.link_to_document(ia_opts)).to have_tag('a', :href => ia_url)
    end
    it 'contains a context-href value' do
      expect(described_class.link_to_document(ia_opts)).to have_tag('data', :'context-href' => ia_context_href_url)
    end
  end
end
