describe BlacklightInternetArchive::Client do

  let(:connection_options) { { url: 'https://archive-it.org/collections/1068', read_timeout: 42, open_timeout: 43, update_format: :xml } }

  let(:client) do
    BlacklightInternetArchive::Client.new connection_options
  end

  context 'execute' do

    it 'should return 200 on execute' do
      request_options = { :data => 'the data', :method => :post, :headers => { 'Content-Type' => 'text/plain' } }
      expect(client).to receive(:execute).with(hash_including(request_options)).and_return(:status => 200)
      client.execute request_options
    end
  end

  context 'build_request' do
    let(:path) { connection_options[:url] }
    let(:opts) { { 'q' => 'torture', 'f' => { 'meta_Subject' => ['Human rights', 'Torture'] } } }
    let(:opts_qstring) { 'https://archive-it.org/collections/1068.json?page=1&pageSize=10&q=torture&fc=meta_Subject%3AHuman+rights&fc=meta_Subject%3ATorture' }
    let(:multi_facet_opts) { { 'q' => 'torture', 'f' => { 'meta_Language' => ['English'], 'meta_Subject' => ['Human rights', 'Torture'] } } }
    let(:multi_facet_opts_qstring) { 'https://archive-it.org/collections/1068.json?page=1&pageSize=10&q=torture&fc=meta_Language%3AEnglish&fc=meta_Subject%3AHuman+rights&fc=meta_Subject%3ATorture' }
    let(:request) { client.build_request(path, opts) }
    let(:request_multifacet) { client.build_request(path, multi_facet_opts) }

    it 'should return an array containing a params array' do
      expect(request[:params]).to be_an Hash
    end

    it 'should add a rows param to the request object' do
      expect(request[:params][:rows]).to be_an Integer
    end

    it 'should add a start param to the request object' do
      expect(request[:params][:rows]).to be_an Integer
    end

    it 'should include all facet options in query string' do
      expect(request[:params][:uri]).to eq(opts_qstring)
    end

    it 'should construct a multiple facet query string' do
      expect(request_multifacet[:params][:uri]).to eq(multi_facet_opts_qstring)
    end
  end
end
