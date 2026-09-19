Rails.application.config.to_prepare do
  class ActiveStorage::Attachment < ActiveStorage::Record
    DEFAULT_OPTIONS = {
      only: [],
      methods: [ :id, :signed_id, :url, :name ]
    }

    # Disk services generate their URLs from ActiveStorage::Current.url_options,
    # which is only set during a request. When the service is a disk service,
    # return a relative path instead so serialization works outside requests.
    def url(*args, **options)
      if blob.service.is_a?(ActiveStorage::Service::DiskService)
        Rails.application.routes.url_helpers.rails_storage_proxy_path(self, only_path: true)
      else
        blob.url(*args, **options)
      end
    end

    def serializable_hash(options = {})
      options.reverse_merge! DEFAULT_OPTIONS
      if options[:url] == :redirect
        super(options.without(:url)).merge(
          url: Rails.application.routes.url_helpers.rails_storage_redirect_path(self, only_path: true)
        )
      elsif options[:url] == :proxy
        super(options.without(:url)).merge(
          url: Rails.application.routes.url_helpers.rails_storage_proxy_path(self, only_path: true)
        )
      else
        super(options)
      end
    end
  end
end
