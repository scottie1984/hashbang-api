require 'bcrypt'
require 'net/smtp'
require 'yaml'

$db = SQLite3::Database.open './hashbang.db'

  class User
    
    /USERS =/ 
    
    CONFIG = YAML.load_file("./config/config.yml") unless defined? CONFIG
    
    include BCrypt

    attr_reader :name
    attr_reader :id
    attr_reader :token
    
    def initialize(id, name, token)
      @id = id
      @name = name
      @token = token
    end
    
    def self.usernameDoesNotExist(username)
      row = $db.get_first_row("select * from users where username = ?", username)
      userDoesNotExists = false
      if row == nil
        userDoesNotExists = true
      end
      userDoesNotExists
    end

    def self.emailDoesNotExist(email)
      row = $db.get_first_row("select * from users where email = ?", email)
      emailDoesNotExists = false
      if row == nil
        emailDoesNotExists = true
      end
      emailDoesNotExists
    end    

    def self.getEmailAddress(userId)
      $db.get_first_row("select email from users where id = ?", userId)
    end   
    
    def self.save(username, password, email)
      insert =  <<-SQL
        INSERT INTO users
        values (NULL, ?, ?, ?, "inactive", 0)
        SQL
      $db.execute(insert, username, Password.create(password),email)
      userId = $db.last_insert_row_id()
      
      token = createToken(userId)
      sendNewUserEmail(email, token)  
    end
    
    def self.sendNewUserEmail(email, token)
      message = <<-MESSAGE_END
      From: Social Challanges <me@fromdomain.com>
      To: A Test User <#{email}>
      Subject: SMTP e-mail test

      Please use this token to login http://#{CONFIG['frontend_url']}/#!/user/#{token}
      MESSAGE_END

      Net::SMTP.start('localhost', 1025) do |smtp|
        smtp.send_message message, 'me@fromdomain.com', 
                                   'test@todomain.com'
      end
    end
    
    def self.sendForgotPassword(email)
      row = $db.get_first_row("select * from users where email = ? and status='active' and loginAttempts < 5", email)
      if row != nil
        token = createToken(row[0]) 
        sendForgotPasswordEmail(email, token)
      end
    end
    
    def self.createToken(userId)
      token = SecureRandom.uuid
        insertToken =  <<-SQL
          INSERT INTO user_token
          values (NULL, ?, datetime('now', '+30 minutes'), ?)
          SQL
      $db.execute(insertToken, userId, token)
      token
    end
    
    def self.sendForgotPasswordEmail(email, token)
      message = <<-MESSAGE_END
      From: Social Challanges <me@fromdomain.com>
      To: A Test User <#{email}>
      Subject: SMTP e-mail test

      Please use this token to change your password http://#{CONFIG['frontend_url']}/#!/forgot/#{token}
      MESSAGE_END

      Net::SMTP.start('localhost', 1025) do |smtp|
        smtp.send_message message, 'me@fromdomain.com', 
                                   'test@todomain.com'
      end
    end
    
    def self.getIdFromToken(token)
      tokenDetails = getActiveToken(token)
      id = -1
      if tokenDetails != nil
        id = tokenDetails[1]
      end
      id
    end
    
    def self.activate(token)
      tokenDetails = getActiveToken(token)
      if tokenDetails != nil
        activateUserAccount(tokenDetails[1])
        true
      else
        false
      end
    end
    
    def self.activateUserAccount(id)
      update =  <<-SQL
        update users
        set status = "active"  
        where id = ?
        SQL
        $db.execute(update, id)
    end
    
    def self.getActiveToken(token)
      $db.get_first_row("select * from user_token where token = ? and expires > datetime('now')", token)
    end
    
    def self.changePassword(userid, password)
      update =  <<-SQL
        update users
        set password = ? 
        where id = ?
        SQL
        $db.execute(update, Password.create(password), userid)
    end

    class << self
      
      include BCrypt

      def get(token)
        row = $db.get_first_row("select * from session where token = ? and expires > datetime('now')", token)
        if row != nil
          $db.execute( "update session set expires= datetime('now', '+30 minutes')  where id = ?",  row[0])
          User.new(row[1], row[2], row[5])
        end
      end
      
      def logout(token)
        delete =  <<-SQL
        DELETE FROM session
        WHERE token = ?
        SQL
        $db.execute(delete, token)
      end
      
      def authenticate(u, p)
        row = $db.get_first_row("select * from users where username = ? and status='active' and loginAttempts < 5", u)
        
        if row != nil
          userId = row[0]
          currentPassword = row[2]
          
          matchingPass = false
          matchingPass = Password.new(currentPassword) == p 
        
          if matchingPass == true 
            token = SecureRandom.uuid       
            insertSession(userId, u, token)
            resetLoginAttempts(userId)
          elsif row != nil
            increaseLoginAttempts(userId)
          end

          User.new(userId, u, token) if matchingPass
        end
      end
      
      def insertSession(id, username, token)
        insert =  <<-SQL
        INSERT INTO session
        values (NULL, ? , ? , datetime('now', '+30 minutes'), ?)
        SQL
        $db.execute(insert, id, username, token)
      end 
      
      def resetLoginAttempts(id)
        update =  <<-SQL
          update users
          set loginAttempts = 0
          where id = ?
          SQL
          $db.execute(update, id) 
      end 
      
      def increaseLoginAttempts(id)
        update =  <<-SQL
          update users
          set loginAttempts = loginAttempts + 1 
          where id = ?
          SQL
          $db.execute(update, id)
      end

    end

  end