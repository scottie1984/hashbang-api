require 'grape'
require 'sqlite3'
require 'json'
require 'rack/contrib'
require 'warden'

require_relative './../model/user'
require_relative './../model/warden'
require_relative './../helpers/password_strength'

module SocialChallenges

  class LOGINAPI < Grape::API
    
    use Rack::Session::Cookie, :secret => "replace this with some secret key"

        use Warden::Manager do |manager|
          manager.default_strategies :password
        end

    use Rack::JSONP
    format :json

    get :ping do
      {hello: "pong"}
    end
    
    post 'create' do
      strength = PasswordStrength.calcStrength(params[:password])
      if strength == "strong"
        if params[:password] == params[:confirmPassword]
          if User.usernameDoesNotExist(params[:username])
            User.save(params[:username], params[:password], params[:email])
            { "message" => "user successfully created. You have been sent an email with instructions on how to activate the account" }
            { "status" => "ok" }
          else
            { "status" => "username already in use. Please chose another" }
          end
        else
          { "status" => "passwords do not match" }
        end
      else
        { 
          "status" => "Password not strong enough",
          "message" => "Password is " + strength
        }
      end
    end
  
    post 'check/username' do
      if User.usernameDoesNotExist(params[:username])
        { "status" => "ok" }
      else
        { "status" => "already in use" }
      end
    end

    post 'check/password' do
      strength = PasswordStrength.calcStrength(params[:password])
        { "status" => strength }
    end

    post 'check/email' do
      if User.emailDoesNotExist(params[:email])
        { "status" => "ok" }
      else
        { "status" => "already in use" }
      end
    end

    post 'get/email' do
      email = User.getEmailAddress(params[:userId])
          { "email" => email[0] }
      end

    post 'change-password' do
      env['warden'].authenticate
      error! "Unauthorized", 401 unless env['warden'].user
      
      strength = PasswordStrength.calcStrength(params[:password])
      if strength == "strong"
        if params[:password] == params[:confirmPassword]
          User.changePassword(env['warden'].user.id, params[:password])
          { "status" => "password changed successfully" }
        else
          { "status" => "passwords do not match" }
        end
      else
        { 
          "status" => "Password not strong enough",
          "message" => "Password is " + strength
        }
      end
    end
    
    post 'activate/:token' do
      if User.activate(params[:token])
        { "status" => "Account activated" }
      else
        { "status" => "Invalid token provided" }
      end
    end
    
    post 'forgot-password' do
      User.sendForgotPassword(params[:email])
      { "status" => "email sent to address provided if it is a valid email" } 
    end
    
    post 'forgot-password/:token' do
      strength = PasswordStrength.calcStrength(params[:password])
      if strength == "strong"
        if params[:password] == params[:confirmPassword]
          userId = User.getIdFromToken(params[:token])
          if userId != -1
            User.changePassword(userId, params[:password])
            { "status" => "successfully changed password" }
          else
            { "status" => "token not valid" }
          end          
        else
          { "status" => "passwords do not match" }
        end
      else
        { 
          "status" => "Password not strong enough",
          "message" => "Password is " + strength
        }
      end
    end
    
    post 'login' do
        user = User.authenticate(params[:username], params[:password])
        #error! "Invalid username or password", 401 unless user != nil
        #{ "username" => user.name, "id" => user.id, "token" => user.token }
        if user != nil 
          { "username" => user.name, "id" => user.id, "token" => user.token }
      	else
          { "status" => "Invalid username or password"}
        end 
    end

    post 'logout' do
          user = User.get(params[:token])
          error! "Logged out", 401 unless user != nil

          User.logout(params[:token])
          { "status" => "ok" }
    end
    
    post "active" do
          user = User.get(params[:token])
          if user != nil
            { "active" => true }
          else
            { "active" => false }
          end
    end
    
    post "info" do
          user = User.get(params[:token])
          error! "Unauthorized", 401 unless user != nil
          { "username" => user.name }
    end
    
    post "info2" do
          env['warden'].authenticate
          error! "Unauthorized", 401 unless env['warden'].user
          { "well done" => env['warden'].user.name }
    end

  end

end