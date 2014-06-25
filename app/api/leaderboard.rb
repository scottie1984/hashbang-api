require 'grape'
require 'json'
require 'rack/contrib'

require_relative './../model/uploadmodel'
require_relative './../repository/leaderboard_repository'
require_relative './../repository/tag_repository'

module SocialChallenges

  class LeaderboardAPI < Grape::API

    use Rack::JSONP
    format :json

    get '/:tagName/:numberToGet' do
      JSON.parse(LeaderboardRepository.get_leaderboard_bytagname(params[:tagName], params[:numberToGet]).to_json)
    end
    
    get '/search/:tagName/:numberToGet' do
      tags = TagRepository.alphabetic(params[:tagName], 300000, 'tag')
      json_new = []
      tags.each { |tag|
        objects = LeaderboardRepository.get_leaderboard_bytagname(tag[2], params[:numberToGet])
        json_object = []
        objects.each_with_index {|object, index|
          json_object.push(JSON.parse(
            {
              "number" => index + 1,
              "object" => JSON.parse(object.to_json)
            }.to_json
          )) 
        }
        json_new.push(JSON.parse({
          "tag" => tag[2],
          "objects" => JSON.parse(json_object.to_json)
        }.to_json))
      }
      JSON.parse(json_new.to_json)
    end

  end

end