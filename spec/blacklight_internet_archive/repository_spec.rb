describe BlacklightInternetArchive::Repository do
  let(:blacklight_config) { { url: 'localhost' } }

  xit 'should return a response object' do
    response = described_class.search Blacklight::SearchBuilder.new
    expect(response).to be_an_instance_of(BlacklightInternetArchive::Response)
  end

  xit 'should build an BlacklightInternetArchive client connection' do
    client = described_class.build_connection
    expect(client).to be_an_instance_of(BlacklightInternetArchive::Client)
  end
end
