require 'rails_helper'

RSpec.describe CatalogController do

    context 'for an explicitly provided class' do

      it 'resolves to the custom implementation' do
        expect(CatalogController.blacklight_config.repository_class).to eq InternetArchive::Repository
      end

    end

  end

