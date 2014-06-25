require 'json'

class Rating

  attr_reader :userid, :againstTag, :objectId, :score

  def initialize(userid, againstTag, objectId, score)
    @userid = userid
    @againstTag = againstTag
    @objectId = objectId
    @score = score
  end

end
