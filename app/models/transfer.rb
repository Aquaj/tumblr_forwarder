class Transfer
  include ActiveModel::Model

  attr_accessor :source_consumer_key,
                :source_consumer_secret,
                :source_token,
                :source_token_secret,
                :source_blog,
                :destination_consumer_key,
                :destination_consumer_secret,
                :destination_token,
                :destination_token_secret,
                :destination_blog,
                :source_tag

  validates :source_consumer_key,
            :source_consumer_secret,
            :source_token,
            :source_token_secret,
            :source_blog,
            :destination_consumer_key,
            :destination_consumer_secret,
            :destination_token,
            :destination_token_secret,
            :destination_blog,
            :source_tag, presence: true

  def execute
    # TODO
    Rails.logger.info "Launched!"
    post_ids = retrieve_source_posts
    forward_posts post_ids
    Rails.logger.info "Done!"
    byebug
  end

  def retrieve_source_posts
    post_ids = []
    old_post_ids = nil
    total_post_count = 1
    Rails.logger.info "Beginning post fetching..."
    until post_ids.count >= total_post_count || old_post_ids == post_ids
      result = getter_client.posts(source_blog_path, tag: source_tag, offset: post_ids.count)
      total_post_count = result['total_posts']
      Rails.logger.info "= Fetched #{post_ids.count} / #{total_post_count}..."
      old_post_ids = post_ids
      post_ids += result['posts'].map { |p| p.slice('id', 'reblog_key').merge('blog' => result['blog']['uuid']) }
      post_ids.uniq!
    end
    Rails.logger.info "Done fetching posts!"
    post_ids
  end

  def forward_posts posts
    Rails.logger.info "Reblogging posts to destination blog..."
    posts.each_with_index do |post, index|
      Rails.logger.info "= Reblogging post #{index}/#{posts.count}..."
      query_params = {
        parent_tumblelog_uuid: post['blog'],
        reblog_key: post['reblog_key'],
        id: post['id'] }
      setter_client.reblog(destination_blog_path, state: 'draft', **query_params)
    end
    Rails.logger.info "Done reblogging posts to destination blog !"
  end

  def source_blog_path
    "#{source_blog}.tumblr.com"
  end

  def destination_blog_path
    "#{destination_blog}.tumblr.com"
  end

  def getter_client
    Tumblr::Client.new(
      consumer_key: source_consumer_key,
      consumer_secret: source_consumer_secret,
      oauth_token: source_token,
      oauth_token_secret: source_token_secret
    )
  end

  def setter_client
    Tumblr::Client.new(
      consumer_key: destination_consumer_key,
      consumer_secret: destination_consumer_secret,
      oauth_token: destination_token,
      oauth_token_secret: destination_token_secret
    )
  end
end
