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
      puts tag
      if minCount > tag['numofobjects'].to_i then
        minCount = tag['numofobjects'].to_i
      end

      if maxCount < tag['numofobjects'].to_i then
        maxCount = tag['numofobjects'].to_i
      end
      
      randomObject = TagUploadRepository.get_random_object_bytagname tag['tagname'], Array[-1], tag['type']
      
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
        "id"=> tag['id'], 
        "tag" => tag['tagname'],
        "count" => tag['numofobjects'],
        "type" => type,
        "video_id" => video_id,
        "random_id" => randomId,
        "file_name" => "#{CONFIG['backend_url']}/#{video_id}",
        "file_name_thumb" => "#{CONFIG['backend_url']}/#{video_id.split(".")[0]}_thumb.jpg",
        "file_name_medium" => "#{CONFIG['backend_url']}/#{video_id.split(".")[0]}_medium.jpg",
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
