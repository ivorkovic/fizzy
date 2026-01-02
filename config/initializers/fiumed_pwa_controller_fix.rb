# Fix: Allow unauthenticated access to service worker and manifest
# Without this, the service worker endpoint redirects to login,
# breaking PWA installation and updates, especially on iOS.

Rails.application.config.to_prepare do
  PwaController.class_eval do
    # Skip authentication for PWA assets
    allow_unauthenticated_access only: [:service_worker, :manifest]
  end
end
