require_relative './../repository/tag_repository'
require_relative './../repository/leaderboard_repository'

class UploadModelHelper

  def self.cast_upload_results(results)
    uploads = Array.new
    results.each { |r|
      upload = Uploadmodel.new(r[2], r[3], r[4], r[12], r[9], r[10], r[1], r[0], r[6], r[7], r[8], r[14])
      upload.tags = TagRepository.find_by_object_id upload.id 
      tags_rank = Hash.new
      upload.tags.each { |tag|
        leaderboard = LeaderboardRepository.get_add_leaders_bytagname(tag.tagName)
        tags_rank[tag.tagName] = leaderboard.index { |x| x[0] == r[0] } + 1
      }
      upload.tags_with_rank = tags_rank
      upload.comments = CommentRepository.find_by_object_id upload.id
      uploads << upload 
    }
    uploads
  end

end
