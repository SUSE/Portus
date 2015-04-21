class Image < ActiveRecord::Base
  belongs_to :repository
  has_many :tags

  PUSH_EVENT_FIND_TOKEN_REGEXP = %r|manifests/(?<tag>.*)$|

  def self.handle_push_event(event)
    if event['target']['repository'].include?('/')
      repo_name, image_name = event['target']['repository'].split('/', 2)
    else
      image_name = event['target']['repository']
    end

    match = PUSH_EVENT_FIND_TOKEN_REGEXP.match(event['target']['url'])
    if match
      tag_name = match['tag']
    else
      logger.error("Cannot find tag inside of event url: #{event['target']['url']}")
      return nil
      # TODO: raise exception?
    end

    if repo_name
      repository = Repository.where(name: repo_name).first_or_create(name: repo_name)
    end

    image = Image.where(name: image_name).first_or_create(name: image_name)
    image.tags.where(name: tag_name).first_or_create(name: tag_name)

    repository.images << image if repository
    image
  end

end
