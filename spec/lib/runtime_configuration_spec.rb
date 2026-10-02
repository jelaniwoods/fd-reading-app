require "rails_helper"

RSpec.describe "Production polling defaults" do
  around do |example|
    keys = %w[JOB_CONCURRENCY SOLID_QUEUE_DISPATCH_INTERVAL SOLID_QUEUE_POLL_INTERVAL SOLID_CABLE_POLL_INTERVAL]
    previous = keys.to_h { |key| [key, ENV[key]] }
    keys.each { |key| ENV.delete(key) }
    example.run
  ensure
    previous.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
  end

  it "keeps default Queue worker polling at or above the idle-traffic floor" do
    config = Rails.application.config_for(:queue, env: :production)
    interval = config.fetch(:workers).first.fetch(:polling_interval)

    expect(interval).to(be >= 1.second, <<~MESSAGE)
      Production Queue worker polling defaults to #{interval} seconds (SOLID_QUEUE_POLL_INTERVAL).
      A default below 1 second increases idle database traffic and can consume metered bandwidth.
      See DEPLOY.md#queue-and-cable-polling-is-metered-bandwidth.
      Change this guard with any deliberate change to the application's polling policy.
    MESSAGE
  end

  it "keeps default Queue dispatcher polling at or above the idle-traffic floor" do
    config = Rails.application.config_for(:queue, env: :production)
    interval = config.fetch(:dispatchers).first.fetch(:polling_interval)

    expect(interval).to(be >= 1.second, <<~MESSAGE)
      Production Queue dispatcher polling defaults to #{interval} seconds (SOLID_QUEUE_DISPATCH_INTERVAL).
      A default below 1 second increases idle database traffic and can consume metered bandwidth.
      See DEPLOY.md#queue-and-cable-polling-is-metered-bandwidth.
      Change this guard with any deliberate change to the application's polling policy.
    MESSAGE
  end

  it "keeps default Cable polling at or above the idle-traffic floor" do
    config = Rails.application.config_for(:cable, env: :production)
    allow(Rails.application).to receive(:config_for).with("cable").and_return(config)

    interval = SolidCable.polling_interval

    expect(interval).to(be >= 1.second, <<~MESSAGE)
      Production Cable polling defaults to #{interval.to_f} seconds (SOLID_CABLE_POLL_INTERVAL).
      A default below 1 second increases idle database traffic and can consume metered bandwidth.
      See DEPLOY.md#queue-and-cable-polling-is-metered-bandwidth.
      Change this guard with any deliberate change to the application's polling policy.
    MESSAGE
  end
end
