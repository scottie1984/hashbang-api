require_relative './../helpers/upload_model_helper'
require 'pg'

env = ENV['DATABASE_URL'] || 'localhost'

if env == 'localhost'
  $conn = PGconn.open(:dbname => 'hashbang', :user=> 'postgres')
else
  db_parts = ENV['DATABASE_URL'].split(/\/|:|@/)
  username = db_parts[3]
  password = db_parts[4]
  host = db_parts[5]
  db = db_parts[7]
  $conn = PGconn.open(:host =>  host, :dbname => db, :user=> username, :password=> password)
end

class TagUploadRepository

def self.get_random_object_bytagname(id, excludeIds, tagType)
  select =  <<-SQL
    SELECT *, u.type as uploadtype, u.id as upid
    FROM uploads u, users us, tag_objects, tags
    WHERE u.id = tag_objects.objectId
    AND tags.id = tag_objects.tagId
    AND u.userid = us.id
    AND tags.tagName = $1
    AND tags.type = $2
    SQL
  results = $conn.exec_params(select, [id, tagType])
  
  #puts results
  #puts excludeIds
  
  uploads = UploadModelHelper.cast_upload_results results
  #uploads.each {|upload| puts upload.id}
  uploads_temp = uploads.to_a
  uploads_temp.delete_if { |upload| excludeIds.include?(upload.id.to_i) }
  #
  uploads_temp.each {|upload| puts upload.id}
  
  if uploads.count != 0
    randIndex = Random.new.rand(0..uploads.count-1)
    uploads[randIndex]
  else
    false
  end
end

end