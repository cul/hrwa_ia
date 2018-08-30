# make response blacklight-ready
module BlacklightInternetArchive
  class HashWithResponse < Hash
    include BlacklightInternetArchive::Response

    def initialize(request, response, result)
      super()
      initialize_response(request, response, result || {})
    end
  end
end
