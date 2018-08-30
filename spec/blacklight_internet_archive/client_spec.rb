describe BlacklightInternetArchive::Client do

  let(:connection_options) { { url: 'https://archive-it.org/collections/1068', read_timeout: 42, open_timeout: 43, update_format: :xml } }
  let(:client) do
    BlacklightInternetArchive::Client.new connection_options
  end
  let(:path) { connection_options[:url] }
  let(:opts) { { 'q' => 'torture', 'f' => { 'meta_Subject' => ['Human rights', 'Torture'] } } }
  let(:request) { client.build_request(path, opts) }

  describe '.execute' do
    it 'should return 200 on execute' do
      request_options = { :data => 'the data', :method => :post, :headers => { 'Content-Type' => 'text/plain' } }
      expect(client).to receive(:execute).with(hash_including(request_options)).and_return(:status => 200)
      client.execute request_options
    end
  end

  describe '.build_request' do
    it 'returns a hash containing a params hash' do
      expect(request[:params]).to be_an Hash
    end
  end

  describe '.calculate_start' do
    it 'sets start to zero if page is less than 2' do
      expect(client.calculate_start({'page' => 1, 'pageSize' => 10})).to eq(0)
    end
    it 'sets start to 40 if page is 5' do
      expect(client.calculate_start({'page' => 5, 'pageSize' => 10})).to eq(40)
    end
  end

  describe '.construct_facet_string' do
    let(:facet_string) { 'fc=meta_Subject%3AHuman+rights&fc=meta_Subject%3ATorture' }
    let(:multi_facet_opts) { { 'q' => 'torture', 'f' => { 'meta_Language' => ['English'], 'meta_Subject' => ['Human rights', 'Torture'] } } }
    let(:multi_facet_string) { 'fc=meta_Language%3AEnglish&fc=meta_Subject%3AHuman+rights&fc=meta_Subject%3ATorture' }

    it 'includes all facet options in query string' do
      expect(client.construct_facet_string(opts)).to eq(facet_string)
    end

    it 'constructs a multiple facet query string' do
      expect(client.construct_facet_string(multi_facet_opts)).to eq(multi_facet_string)
    end
  end
end
