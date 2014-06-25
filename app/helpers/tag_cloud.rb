require_relative './../model/tag'
require_relative './../repository/tag_upload_repository'

require 'yaml'

class TagCloud
  
  CONFIG = YAML.load_file("./config/config.yml") unless defined? CONFIG

  def self.tag_cloud(tags)
    json_new = []
    minCount = 9999999
    maxCount = 0
    tagJson = tags.each { |tag|
      if minCount > tag[3] then
        minCount = tag[3]
      end

      if maxCount < tag[3] then
        maxCount = tag[3]
      end
      
      randomObject = TagUploadRepository.get_random_object_bytagname tag[2], Array[-1], tag[4]
      
      randomId = 1
      type = 'image'
      video_id = 'xxx'
      md5gravatar = 'xxx'
      if randomObject != false then
        randomId = randomObject.id
        type = randomObject.type
        video_id = randomObject.file_name
        md5gravatar = Digest::MD5.hexdigest(randomObject.gravatar)
      end
        
      json_new.push(JSON.parse({
        "id"=> tag[0], 
        "tag" => tag[2],
        "count" => tag[3],
        "type" => type,
        "video_id" => video_id,
        "random_id" => randomId,
        "file_name" => "http://#{CONFIG['backend_url']}/upload/#{randomId}/download",
        "file_name_thumb" => "http://#{CONFIG['backend_url']}/upload/#{randomId}/download/thumb",
        "file_name_medium" => "http://#{CONFIG['backend_url']}/upload/#{randomId}/download/medium",
        "gravatar" => md5gravatar
      }.to_json))
  }
  totalCount = tags.count
    
    [
        {
            "totalCount" => totalCount,
            "minCount" => minCount,
            "maxCount" => maxCount,
            "tagCloud" => JSON.parse(json_new.to_json)
        }
    ].to_json
  end

end
