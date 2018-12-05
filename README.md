== README

A blacklight front-end for Internet Archive collections

In CatalogController, set 

    config.repository_class = InternetArchive::Repository
    config.response_model = InternetArchive::BlacklightResponse

For index search results metadata display, include the following:


    config.add_index_field 'meta_Title', label: 'Title'
    config.add_index_field 'linked_url', label: 'URL'
    config.add_index_field 'description', label: 'Description'
    config.add_index_field 'linked_numCaptures', label: '# of Captures'
    config.add_index_field 'linked_firstCapture_date', label: 'First Captured'
    config.add_index_field 'linked_lastCapture_date', label: 'Last Captured'    
    config.add_index_field 'linked_numVideos', label: 'Videos'
    config.add_index_field 'meta_Subject', label: 'Subject'
    config.add_index_field 'websiteGroup', label: 'Group'
    config.add_index_field 'meta_Creator', label: 'Creator'
    config.add_index_field 'meta_Language', label: 'Language'
    config.add_index_field 'meta_Coverage', label: 'Coverage'
    config.add_index_field 'meta_Collector', label: 'Collector'

