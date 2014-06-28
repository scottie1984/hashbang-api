require 'json'
require 'yaml'

class Tag

  attr_reader :tagName, :userId, :id, :tag_datetime, :numOfObjects, :type
  
  CONFIG = YAML.load_file("./config/config.yml") unless defined? CONFIG

  def initialize(tagName, userId, type = 'tag', id = nil, tag_datetime = Time.now.to_s, numOfObjects = 0)
    @tagName = tagName
    @userId = userId
    @id = id
    @tag_datetime = tag_datetime
    @numOfObjects = numOfObjects
    @type = type
  end

  def to_json(*a)
    @tagName.to_json(*a)
  end
  
  def self.returnJSON(currentObject, previousObject, nextObject)
    [{
      "current"       => JSON.parse(currentObject.to_json), "previous" => {"id" => previousObject.id, "original_file_name" => previousObject.original_file_name, "type" => previousObject.type, "overallScore" => previousObject.overallScore, "file_name_medium" => "#{CONFIG['backend_url']}/#{previousObject.file_name.split(".")[0]}_medium.jpg", "file_name" => "#{CONFIG['backend_url']}/#{previousObject.file_name}"}, "next" => {"id" => nextObject.id, "original_file_name" => nextObject.original_file_name,  "type" => nextObject.type, "file_name_medium" => "#{CONFIG['backend_url']}/#{nextObject.file_name.split(".")[0]}_medium.jpg", "overallScore" => nextObject.overallScore, "file_name" => "#{CONFIG['backend_url']}/#{nextObject.file_name}"}
      }].to_json
  end
  
  def self.returnJSONNoNext(currentObject, previousObject)
    [{
      "current"       => JSON.parse(currentObject.to_json), "previous" => {"id" => previousObject.id, "type" => previousObject.type, "overallScore" => previousObject.overallScore, "file_name" => "#{CONFIG['backend_url']}/#{previousObject.file_name}","file_name_medium" => "#{CONFIG['backend_url']}/#{previousObject.file_name.split(".")[0]}_medium.jpg", "original_file_name" => previousObject.original_file_name}, "next" => {"type" => 'end'}
      }].to_json
  end
  
  def self.returnJSONNoPrevious(currentObject, nextObject)
    [{
      "current"       => JSON.parse(currentObject.to_json), "next" => {"id" => nextObject.id, "type" => nextObject.type, "overallScore" => nextObject.overallScore, "file_name" => "#{CONFIG['backend_url']}/#{nextObject.file_name}", "file_name_medium" => "#{CONFIG['backend_url']}/#{nextObject.file_name.split(".")[0]}_medium.jpg", "original_file_name" => nextObject.original_file_name}
      }].to_json
  end
  
  def self.returnJSONPreviousRandomTag(previousObject, randomTag)
    [{
      "randomTag" => randomTag, "previous" => {"id" => previousObject.id, "type" => previousObject.type, "overallScore" => previousObject.overallScore, "file_name" => "#{CONFIG['backend_url']}/#{previousObject.file_name}","file_name_medium" => "#{CONFIG['backend_url']}/#{previousObject.file_name.split(".")[0]}_medium.jpg", "original_file_name" => previousObject.original_file_name}, "next" => {"type" => 'end'}
      }].to_json
  end
  
  def self.returnJSONPreviousRandomTagWithNext(previousObject, randomTag, nextObject)
    [{
      "randomTag" => randomTag, "previous" => {"id" => previousObject.id, "type" => previousObject.type, "overallScore" => previousObject.overallScore, "file_name" => "#{CONFIG['backend_url']}/#{previousObject.file_name}","file_name_medium" => "#{CONFIG['backend_url']}/#{previousObject.file_name.split(".")[0]}_medium.jpg", "original_file_name" => previousObject.original_file_name}, "next" => {"id" => nextObject.id, "type" => nextObject.type, "overallScore" => nextObject.overallScore, "file_name" => "#{CONFIG['backend_url']}/#{nextObject.file_name}", "file_name_medium" => "#{CONFIG['backend_url']}/#{nextObject.file_name.split(".")[0]}_medium.jpg", "original_file_name" => nextObject.original_file_name}
      }].to_json
  end
  
  def self.returnJSONNoPreviousNoNext(currentObject)
    [{
      "current"       => JSON.parse(currentObject.to_json), "next" => {"type" => 'end'}
      }].to_json
  end

end
