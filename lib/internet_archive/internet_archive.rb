module InternetArchive

  def self.connect args
    connection = args[:url]
    opts = args[:opts]

    Client.new connection, opts
  end

end