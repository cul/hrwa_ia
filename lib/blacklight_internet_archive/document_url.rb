module BlacklightInternetArchive
  # override blacklight search state url_for_document
  class DocumentUrl < Blacklight::SearchState
    ##
    # Extension point for downstream applications
    # to provide more interesting routing to
    # documents
    def url_for_document(doc, options = {})
      # if respond_to?(:blacklight_config) &&
      #     blacklight_config.show.route &&
      #     (!doc.respond_to?(:to_model) || doc.to_model.is_a?(SolrDocument))
      #   route = blacklight_config.show.route.merge(action: :show, id: doc).merge(options)
      #   route[:controller] = params[:controller] if route[:controller] == :current
      #   route
      # else
      #   doc
      # end
    end
  end
end