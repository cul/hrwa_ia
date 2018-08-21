describe BlacklightInternetArchive::Repository do
  let(:blacklight_config) { {:url => 'localhost'} }

  let(:repository) do
    # BlacklightInternetArchive::Repository.new blacklight_config builder
    BlacklightInternetArchive::Repository.new
  end

  it 'should return a response object' do
    response = repository.search
    expect(response).to be_an_instance_of(BlacklightInternetArchive::Response)
  end

  it 'should build an BlacklightInternetArchive client connection' do
    client = repository.build_connection
    expect(client).to be_an_instance_of(BlacklightInternetArchive::Client)
  end
end
