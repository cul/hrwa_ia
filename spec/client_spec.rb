require 'rails_helper'

describe InternetArchive::Client do

  let(:connection_options) { { url: "https://archive-it.org/collections/1068", read_timeout: 42, open_timeout: 43, update_format: :xml } }

  let(:client) do
    InternetArchive::Client.new connection_options
  end

  context "execute" do

    it 'should return 200 on execute' do
      request_options = {:data => "the data", :method=>:post, :headers => {"Content-Type" => "text/plain"}}
      expect(client).to receive(:execute).with(hash_including(request_options)).and_return(:status => 200)
      client.execute request_options
    end
  end


  context "build_request" do

    let(:path) { connection_options[:url] }
    let(:opts) { {'q' => 'query'} }
    let (:request) { client.build_request(path, opts) }

    it 'should return an array containing a params array' do
      expect(request[:params]).to be_an Hash
    end

    it 'should add a rows param to the request object' do
      expect(request[:params][:rows]).to be_an Integer
    end

    it 'should add a start param to the request object' do
      expect(request[:params][:rows]).to be_an Integer
    end


  end


end
