require 'grape'
require 'json'
require 'rack/contrib'

require_relative './../repository/user_repository'

module SocialChallenges

  class UsersAPI < Grape::API

    use Rack::JSONP
    format :json

    get '/popular/:number' do
      JSON.parse(TagCloud.tag_cloud(UserRepository.popular(params[:number])))
    end

  end

end