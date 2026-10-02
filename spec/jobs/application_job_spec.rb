require "rails_helper"

RSpec.describe ApplicationJob, type: :job do
  self.use_transactional_tests = false

  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
    example.run
  ensure
    ActiveJob::Base.queue_adapter = original_adapter
  end

  it "enqueues only after the surrounding database transaction commits" do
    deferred = have_enqueued_job(described_class)
    committed = have_enqueued_job(described_class).exactly(:once)
    expect {
      ActiveRecord::Base.transaction do
        expect { described_class.perform_later }.not_to deferred, -> {
          "#{deferred.failure_message_when_negated}\n" \
            "ApplicationJob defers enqueueing so workers cannot race uncommitted records. " \
            "If changing this policy intentionally, update this spec; see README.md#background-job-transactions."
        }
      end
    }.to committed, -> {
      "#{committed.failure_message}\n" \
        "ApplicationJob should release deferred work after commit. " \
        "If changing this policy intentionally, update this spec; see README.md#background-job-transactions."
    }
  end

  it "discards jobs when the surrounding database transaction rolls back" do
    rolled_back = have_enqueued_job(described_class)
    expect {
      ActiveRecord::Base.transaction do
        described_class.perform_later
        raise ActiveRecord::Rollback
      end
    }.not_to rolled_back, -> {
      "#{rolled_back.failure_message_when_negated}\n" \
        "ApplicationJob must not enqueue work for rolled-back changes. " \
        "If changing this policy intentionally, update this spec; see README.md#background-job-transactions."
    }
  end
end
