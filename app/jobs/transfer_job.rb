class TransferJob < ApplicationJob
  def perform(transfer)
    FetchingJob.perform_now(transfer)
    ForwardingJob.perform_now(transfer)
  end
end
