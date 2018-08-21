# make response blacklight-ready
class BlacklightInternetArchive::HashWithResponse < Hash
  include BlacklightInternetArchive::Response

  def initialize(request, response, result)
    super()
    initialize_response(request, response, result || {})
  end
end
