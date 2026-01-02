# frozen_string_literal: true

# Fix SQLite contention issues by setting busy_timeout
# When database is locked, wait up to 10 seconds instead of failing immediately
# This prevents cascade failures when Solid Queue and web requests compete for locks

Rails.application.config.after_initialize do
  if ActiveRecord::Base.connection.adapter_name == 'SQLite'
    # Set on all database connections
    ActiveRecord::Base.connection_pool.connections.each do |conn|
      conn.raw_connection.busy_timeout = 10_000  # 10 seconds
    end
    
    # Also set for new connections
    ActiveRecord::Base.connection.raw_connection.busy_timeout = 10_000
    
    # Log that we set it
    Rails.logger.info "[SQLite] Set busy_timeout to 10000ms on primary connection"
  end
rescue => e
  Rails.logger.warn "[SQLite] Could not set busy_timeout: #{e.message}"
end
