# Disable public signups - only allow join codes
Rails.application.config.to_prepare do
  SignupsController.class_eval do
    before_action :block_public_signups

    private
      def block_public_signups
        redirect_to new_session_path, alert: "Public signups are disabled. Please use an invite link."
      end
  end
end
