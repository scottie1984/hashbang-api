require 'grape'
require 'json'
require 'rack/contrib'

require_relative './../model/rating'
require_relative './../repository/rating_repository'

module SocialChallenges

  class RatingAPI < Grape::API

    use Rack::JSONP
    format :json

    post '/add' do
      userid = params[:userId]
      againstTag = params[:againstTag]
      objectId = params[:objectId]
      score = params[:score]
      rating = Rating.new userid, againstTag, objectId, score
      RatingRepository.save rating
      RatingRepository.updateScore rating.objectId, score
    end

  end

end