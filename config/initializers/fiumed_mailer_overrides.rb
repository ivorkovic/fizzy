Rails.application.config.to_prepare do
  ApplicationMailer.default from: ENV['FROM_EMAIL'] || ENV['SMTP_USER_NAME'] || 'noreply@fiumed.cloud'
end
