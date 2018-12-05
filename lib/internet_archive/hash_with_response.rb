class InternetArchive::HashWithResponse < Hash
  include InternetArchive::Response

  def initialize(request, response, result)
    super()
    initialize_response(request, response, result || {})
  end
end