require 'rails_helper'

describe InternetArchive::Repository do

  let(:blacklight_config) { CatalogController.config }

  let(:repository) do
    InternetArchive::Repository.new blacklight_config
  end


it 'should return a response object' do
	response = repository.search
	expect(response).to be_an_instance_of(InternetArchive::Response)
end

 it 'should build an InternetArchive client connection' do
	client = repository.build_connection
	expect(client).to be_an_instance_of(InternetArchive::Client)
 end




 it 'should retrieve connection ops from config' do
 end


end