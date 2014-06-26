require_relative './../repository/tag_repository'
require_relative './../repository/leaderboard_repository'

class UploadModelHelper

  def self.cast_upload_results(results)
    uploads = Array.new
    results.each { |r|
      puts r
      puts r['upid']
      upload = Uploadmodel.new(r['uploadtype'], r['file_name'], r['original_file_name'], r['userid'], r['title'], r['description'], r['upload_datetime'], r['upid'], r['overallscore'], r['numofratings'], r['averagescore'], r['email'])
      upload.tags = TagRepository.find_by_object_id upload.id 
      tags_rank = Hash.new
      upload.tags.each { |tag|
        leaderboard = LeaderboardRepository.get_add_leaders_bytagname(tag.tagName)
        #tags_rank[tag.tagName] = leaderboard.index { |x| x[0] == r['id'] } + 1
      }
      upload.tags_with_rank = tags_rank
      upload.comments = CommentRepository.find_by_object_id upload.id
      uploads << upload 
    }
    uploads
  end

end
