describe BlacklightInternetArchive::Repository do
  let(:blacklight_config) { {:url => 'localhost'} }

  let(:repository) do
    BlacklightInternetArchive::Repository.new blacklight_config
  end

  xit 'should return a response object' do
    response = repository.search Blacklight::SearchBuilder.new
    expect(response).to be_an_instance_of(BlacklightInternetArchive::Response)
  end

  xit 'should build an BlacklightInternetArchive client connection' do
    client = repository.build_connection
    expect(client).to be_an_instance_of(BlacklightInternetArchive::Client)
  end
end
