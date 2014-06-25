require_relative './../repository/tag_repository'
require_relative './../repository/user_repository'
require_relative './../model/tag'

class TagHelper

  def self.process_tags(tags_csv, object_id, user_id)
    TagHelper.create_tags_from_csv(tags_csv, user_id).each do |tag|
      tag_id = self.find_or_add_tag tag.tagName, tag.userId
      TagRepository.tagObject object_id, tag_id
    end
    
    username = UserRepository.getUsername user_id
    usertag_id = self.find_or_add_user_tag username, user_id
    TagRepository.tagObject object_id, usertag_id
  end

  def self.create_tags_from_csv(tags_csv, user_id)
    tags_csv.split(',').map { |t| Tag.new t, user_id }
  end
  
  def self.find_or_add_tag(tag, user_id)
    tagLowercase = tag.downcase
    tag_id = TagRepository.findByName tagLowercase
    if tag_id == -1
      tag = Tag.new tagLowercase, user_id, 'tag'
      tag_id = TagRepository.save tag
    end
    tag_id
  end
  
  def self.find_or_add_user_tag(tag, user_id)
    tag_id = TagRepository.findUserTagByName tag
    if tag_id == -1
      tag = Tag.new tag, user_id, 'user'
      tag_id = TagRepository.save tag
    end
    tag_id
  end

  def self.cast_results(results)
    tags = Array.new
    results.each { |r| tags << Tag.new(r[2], r[1], r[0]) }
    tags
  end

end
