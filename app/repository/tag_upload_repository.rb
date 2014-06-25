require_relative './../helpers/upload_model_helper'

$db = SQLite3::Database.open 'hashbang.db'

class TagUploadRepository

def self.get_random_object_bytagname(id, excludeIds, tagType)
  select =  <<-SQL
    SELECT *
    FROM uploads u, users us, tag_objects, tags
    WHERE u.id = tag_objects.objectId
    AND tags.id = tag_objects.tagId
    AND u.userid = us.id
    AND tags.tagName = ?
    AND tags.type = ?
    SQL
  results = $db.execute(select, id, tagType)
  
  uploads = UploadModelHelper.cast_upload_results results
  uploads_temp = uploads
  uploads.delete_if { |upload| excludeIds.include?(upload.id) }
  
  if uploads.count != 0
    randIndex = Random.new.rand(0..uploads.count-1)
    uploads[randIndex]
  else
    false
  end
end

end