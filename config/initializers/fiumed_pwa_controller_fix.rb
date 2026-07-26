# Keep the root service worker available before authentication.
# The manifest is served by Rails::PwaController and does not use Fizzy's
# application authentication filters.

Rails.application.config.to_prepare do
  PwaController.class_eval do
    allow_unauthenticated_access only: :service_worker
  end
end
