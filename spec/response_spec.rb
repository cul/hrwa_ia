require 'rails_helper'

describe InternetArchive::Response do

  let(:ia_json) { IO.read(Rails.root.join("spec", "fixtures", "mwatikho.json")) }

  let(:request) { {} }

  let(:response) do
    InternetArchive::HashWithResponse
  end

  it 'should initialize successfully' do
    # response.new request, response, ia_json
  end

end
