class Transfer < ApplicationRecord
  has_many :posts

  validates :source_consumer_key,
            :source_consumer_secret,
            :source_token,
            :source_token_secret,
            :source_blog,
            :source_tag,
            :destination_consumer_key,
            :destination_consumer_secret,
            :destination_token,
            :destination_token_secret,
            :destination_blog,
            presence: true

  def execute
    Rails.logger.info "Launched!"
    retrieve_source_posts
    forward_posts
    Rails.logger.info "Done!"
  end

  def fetch_posts
    total_post_count = Float::INFINITY
    old_post_count = -1
    Rails.logger.info "Beginning post fetching..."
    until posts.count >= 1500
      result = getter_client.posts(source_blog_path, offset: post_ids.count)
    # until posts.count >= total_post_count || posts.count == old_post_count
    #   result = getter_client.posts(source_blog_path, tag: source_tag, offset: post_ids.count)
      total_post_count = result['total_posts']
      Rails.logger.info "= Fetched #{post_ids.count} / #{total_post_count}..."
      old_post_count = posts.count
      blog = result['blog']
      create_posts(result['posts'], blog)
    end
    Rails.logger.info "Done fetching posts!"
  end

  def create_posts(posts_args, blog)
    new_posts = posts_args.map do |post_args|
      next if posts.where(uuid: post_args['id']).exists?
      attributes = {}
      attributes['uuid']       = post_args['id']
      attributes['blog_uuid']  = blog['uuid']
      attributes['reblog_key'] = post_args['reblog_key']
      attributes['transfer']   = self

      attributes
    end
    Post.create! new_posts.compact
    posts.reload
  end

  def forward_posts
    Rails.logger.info "Reblogging posts to destination blog..."
    to_reblog = posts.where.not(reblogged: true)
    failed = 0
    to_reblog.find_each.each_with_index do |post, index|
      Rails.logger.info "= Reblogging post #{index}/#{to_reblog.count}..."
      success = post.reblog(to: destination_blog_path, tags: [destination_tag])
      failed += 1 unless success
      break Rails.logger.warn <<-MSG if failed >= 5
        Failed to reblog several posts in a row. Delaying reblogs to later.
        Remaining posts: #{to_reblog.count}.
      MSG
    end
    Rails.logger.info "Done reblogging posts to destination blog !"

    posts.where.not(reblogged: true).none?
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
