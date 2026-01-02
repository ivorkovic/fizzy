if Rails.env.production?
  Rails.application.config.action_mailer.delivery_method = :smtp
  Rails.application.config.action_mailer.smtp_settings = {
    address: ENV['SMTP_ADDRESS'] || 'smtp.gmail.com',
    port: ENV['SMTP_PORT'] || 587,
    domain: ENV['SMTP_DOMAIN'] || 'fiumed.hr',
    user_name: ENV['SMTP_USER_NAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: ENV['SMTP_AUTHENTICATION'] || 'plain',
    enable_starttls_auto: ENV['SMTP_ENABLE_STARTTLS_AUTO'] != 'false'
  }
  
  Rails.application.config.action_mailer.default_url_options = { 
    host: 'fizzy.fiumed.cloud', 
    protocol: 'https' 
  }
  
  Rails.application.config.action_mailer.raise_delivery_errors = true
  Rails.application.config.action_mailer.perform_deliveries = true
  
  # Override the default from address to use the authenticated SMTP user
  Rails.application.config.action_mailer.default_options = {
    from: ENV['FROM_EMAIL'] || ENV['SMTP_USER_NAME']
  }
end

# Force synchronous email delivery (bypass Solid Queue for now)
Rails.application.config.active_job.queue_adapter = :inline
