require 'grape'
require 'json'
require 'rack/contrib'

require_relative './../repository/feedback_repository'

module SocialChallenges

  class FeedbackAPI < Grape::API

    use Rack::JSONP
    format :json

    post '/add' do
      errors = Array.new
      feedback = params[:feedback]
      FeedbackRepository.save feedback
      { "status" => "ok"}
    end
    
    get '/all' do
      feedback = FeedbackRepository.all
      JSON.parse(feedback.to_json)
    end

  end

end