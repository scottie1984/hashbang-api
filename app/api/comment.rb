require 'grape'
require 'json'
require 'rack/contrib'

require_relative './../repository/comment_repository'

module SocialChallenges

  class CommentAPI < Grape::API

    use Rack::JSONP
    format :json

    post '/add' do
      errors = Array.new
      user_token = params[:userToken]
      errors << Error.new("user_token", "The userid field is required") if user_token.empty? || user_token == 'undefined'
      error! JSON.parse(errors.to_json), 403 if errors.length > 0
      user = User.get(user_token)
      error! "Unauthorized", 401 unless user != nil
      objectId = params[:objectId]
      comment = params[:comment]
      CommentRepository.save objectId, comment, user.id
      JSON.parse(CommentRepository.find_by_object_id(params[:objectId]).to_json)

    end
    
    get '/delete/:id' do
      id = params[:id]
      CommentRepository.delete id
    end

  end

end