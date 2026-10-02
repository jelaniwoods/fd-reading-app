# Production error tracking is opt-in by access token. Development, test, and
# keyless production stay dormant and make no external requests.
Rollbar.configure do |config|
  config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  config.environment = ENV["ROLLBAR_ENV"].presence || Rails.env

  # Only an explicitly keyed production app reports. Keyless production boots
  # remain fully dormant instead of relying on notifier internals.
  config.enabled = Rails.env.production? && ENV["ROLLBAR_ACCESS_TOKEN"].present?
  config.code_version = ENV["RENDER_GIT_COMMIT"]

  # Rails.error covers jobs and handled errors. The legacy mailer hook would
  # report a failed mail job again before the Rails executor reports it.
  config.enable_rails_error_subscriber = true
  config.disable_action_mailer_monkey_patch = true

  # Rollbar cannot use Rails' precompiled parameter filters (#1207). Remove
  # this compatibility line once https://github.com/rollbar/rollbar-gem/issues/1207 is fixed.
  config.scrub_fields |= Rails.application.config.filter_parameters
  # Auth cookies and Rodauth's regex-filtered link key need explicit names;
  # Turbo's CSRF header is filtered separately from parameters.
  config.scrub_fields |= %i[session remember key]
  config.scrub_headers |= %w[X-CSRF-Token]

  # Rails excludes rendered HTTP rescue responses (4xx) from its reporter.
  # Also ignore these misses in unhandled jobs and handled: false reports.
  # Explicit handled reports bypass level filters and keep their severity.
  config.exception_level_filters.merge!(
    "ActionController::RoutingError" => "ignore",
    "ActiveRecord::RecordNotFound" => "ignore"
  )
end

# Keep request context alive until Rails' executor reports an HTTP failure.
# https://github.com/rollbar/rollbar-gem/issues/1167
Rails.application.config.middleware.move_before(
  ActionDispatch::Executor,
  Rollbar::Middleware::Rails::RollbarMiddleware
)
