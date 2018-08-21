require "blacklight_internet_archive/version"

module BlacklightInternetArchive

  autoload :InternetArchive, 'blacklight_internet_archive/internet_archive'
  autoload :Client, 'blacklight_internet_archive/client'
  autoload :Repository, 'blacklight_internet_archive/repository'
  autoload :Request, 'blacklight_internet_archive/request'
  autoload :Response, 'blacklight_internet_archive/response'
  autoload :ResponseAdapter, 'blacklight_internet_archive/response_adapter'
  autoload :EntityProcessor, 'blacklight_internet_archive/entity_processor'
  autoload :BlacklightResponse, 'blacklight_internet_archive/blacklight_response'
  autoload :HashWithResponse, 'blacklight_internet_archive/hash_with_response'

  def self.connect(args)
    connection = args[:url]
    opts = args[:opts]

    Client.new connection, opts
  end


end
