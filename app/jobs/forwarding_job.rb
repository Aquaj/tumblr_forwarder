class ForwardingJob < ApplicationJob
  def perform(transfer)
    transfer.execute
  end
end
