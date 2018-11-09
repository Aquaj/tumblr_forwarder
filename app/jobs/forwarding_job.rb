class ForwardingJob < ApplicationJob
  def perform(transfer)
    done = transfer.forward_posts
    return TransferMailer.with(transfer: transfer).complete_email.deliver_later if done
    ForwardingJob.set(wait: 90.minutes).perform_later(transfer)
  end
end
