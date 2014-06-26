require 'pg'

require_relative './../model/tag'
require_relative './../model/uploadmodel'
require_relative './../helpers/upload_model_helper'

$conn = PGconn.open(:dbname => 'hashbang')

class LeaderboardRepository
  
  def self.get_leaderboard_bytagname(tag, numberToGet)
    select =  <<-SQL
      SELECT *
      FROM uploads, users, tag_objects, tags
      WHERE uploads.id = tag_objects.objectId
      AND tags.id = tag_objects.tagId
      AND uploads.userid = users.id
      AND tags.tagName = $1
      ORDER BY uploads.overallScore DESC
      LIMIT $2
      SQL
    results = $conn.exec_params(select, [tag, numberToGet])
    uploads = UploadModelHelper.cast_upload_results results
  end
  
  def self.get_add_leaders_bytagname(tag)
    select =  <<-SQL
      SELECT u.id, u.overallScore
      FROM uploads u, tag_objects, tags
      WHERE u.id = tag_objects.objectId
      AND tags.id = tag_objects.tagId
      AND tags.tagName = $1
      ORDER BY u.overallScore DESC
      SQL
    results = $conn.exec_params(select, [tag])
  end
  
end
