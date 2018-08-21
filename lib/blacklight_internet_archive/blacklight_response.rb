module BlacklightInternetArchive
  # make blacklight faceting functionality available to IA response docs
  class BlacklightResponse < Blacklight::Solr::Response
    include Blacklight::Solr::Response::Facets
  end
end
