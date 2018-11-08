class FetchingJob < ApplicationJob
  def perform(transfer)
    transfer.fetch_posts
  end
end
