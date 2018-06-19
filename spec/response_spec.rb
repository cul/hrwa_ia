require 'rails_helper'

describe InternetArchive::Response do

	let(:ia_json) { fixture_to_json('mwatikho.json') }

	let(:request) {  }

	let(:ia_response) {  }


	let(:response) do
		InternetArchive::HashWithResponse
	end

	it 'should initialize successfully' do
		response.new :request, :ia_response, :ia_json
	end

end