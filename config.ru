require './app/api/login'
require './app/api/uploads'
require './app/api/rating'
require './app/api/tag'
require './app/api/leaderboard'
require './app/api/users'
require './app/api/comment'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :post
  end
end

map '/auth' do
  run SocialChallenges::LOGINAPI
end

map '/upload' do
  run SocialChallenges::UploadAPI
end

map '/rating' do
  run SocialChallenges::RatingAPI
end

map '/tag' do
  run SocialChallenges::TagAPI
end

map '/leaderboard' do
  run SocialChallenges::LeaderboardAPI
end

map '/users' do
  run SocialChallenges::UsersAPI
end

map '/comment' do
  run SocialChallenges::CommentAPI
end
