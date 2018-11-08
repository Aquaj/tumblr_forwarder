class Post < ApplicationRecord
  belongs_to :transfer

  validates :uuid, :reblog_key, :blog_uuid, :transfer, presence: true
  validates :uuid, uniqueness: { scope: :transfer_id }

  def reblog(to:, state: :draft, tags: [])
    status = client.reblog(to,
                           id: uuid,
                           state: state,
                           tags: tags.join(','),
                           reblog_key: reblog_key,
                           parent_blog_uuid: blog_uuid)
    success = status['id'].present?
    Rails.logger.warn status["error"] if status.key? "error"
    update!(reblogged: success)
    success
  end

  def client
    transfer.setter_client
  end
end
