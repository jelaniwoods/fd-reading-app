class ApplicationJob < ActiveJob::Base
  # Application enqueue timing policy: see README.md#background-job-transactions.
  self.enqueue_after_transaction_commit = true

  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError
end
