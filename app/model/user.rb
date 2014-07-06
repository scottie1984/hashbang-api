require 'bcrypt'
require 'net/smtp'
require 'yaml'
require 'pg'

env = ENV['DATABASE_URL'] || 'localhost'

if env == 'localhost'
  $conn = PGconn.open(:dbname => 'hashbang', :user=> 'postgres')
else
  db_parts = ENV['DATABASE_URL'].split(/\/|:|@/)
  username = db_parts[3]
  password = db_parts[4]
  host = db_parts[5]
  db = db_parts[7]
  $conn = PGconn.open(:host =>  host, :dbname => db, :user=> username, :password=> password)
end

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
      row = $conn.exec_params("select * from users where username = $1", [username])
      userDoesNotExists = false
      if row.num_tuples.zero?
        userDoesNotExists = true
      end
      userDoesNotExists
    end

    def self.emailDoesNotExist(email)
      row = $conn.exec_params("select * from users where email = $1", [email])
      emailDoesNotExists = false
      if row.num_tuples.zero?
        emailDoesNotExists = true
      end
      emailDoesNotExists
    end    

    def self.getEmailAddress(userId)
      $conn.exec_params("select email from users where id = $1", [userId])
    end   
    
    def self.save(username, password, email)
      insert =  <<-SQL
        INSERT INTO users
        values (DEFAULT, $1, $2, $3, 'inactive', 0)
        RETURNING id
        SQL
      
      userId = $conn.exec_params(insert, [username, Password.create(password),email])
      
      token = createToken(userId[0]['id'])
      sendNewUserEmail(email, token)  
    end
    
    def self.sendNewUserEmail(email, token)
      message = <<-MESSAGE_END
      From: Hashbang.it <hashbang14@gmail.com>
      To: A Test User <#{email}>
      Subject: SMTP e-mail test

      Please use this token to login http://#{CONFIG['frontend_url']}/#!/user/#{token}
      MESSAGE_END
      
      smtp = Net::SMTP.new 'smtp.gmail.com', 587
      smtp.enable_starttls

      smtp.start('gmail.com', ENV['GMAIL_USER'], ENV['GMAIL_PASS'], :login) do |smtp|
        smtp.send_message message, 'hashbang14@gmail.com', email
      end
    end
    
    def self.sendForgotPassword(email)
      row = $conn.exec_params("select * from users where email = $1 and status='active' and loginAttempts < 5", [email])
      if !row.num_tuples.zero?
        token = createToken(row[0]['id']) 
        sendForgotPasswordEmail(email, token)
      end
    end
    
    def self.createToken(userId)
      token = SecureRandom.uuid
        insertToken =  <<-SQL
          INSERT INTO user_token
          values (DEFAULT, $1, now()+ '30 minutes'::interval, $2)
          SQL
      $conn.exec_params(insertToken, [userId, token])
      token
    end
    
    def self.sendForgotPasswordEmail(email, token)
      message = <<-MESSAGE_END
      From: Hashbang.it <hashbang14@gmail.com>
      To: A Test User <#{email}>
      Subject: SMTP e-mail test

      Please use this token to change your password http://#{CONFIG['frontend_url']}/#!/forgot/#{token}
      MESSAGE_END

      smtp = Net::SMTP.new 'smtp.gmail.com', 587
      smtp.enable_starttls

      smtp.start('gmail.com', ENV['GMAIL_USER'], ENV['GMAIL_PASS'], :login) do |smtp|
        smtp.send_message message, 'hashbang14@gmail.com', email
      end
    end
    
    def self.getIdFromToken(token)
      tokenDetails = getActiveToken(token)
      id = -1
      if !tokenDetails.num_tuples.zero?
        id = tokenDetails[0]['userid']
      end
      id
    end
    
    def self.activate(token)
      tokenDetails = getActiveToken(token)
      if !tokenDetails.num_tuples.zero?
        activateUserAccount(tokenDetails[0]['userid'].to_i)
        true
      else
        false
      end
    end
    
    def self.activateUserAccount(id)
      update =  <<-SQL
        update users
        set status = 'active'  
        where id = $1
        SQL
        $conn.exec_params(update, [id])
    end
    
    def self.getActiveToken(token)
      $conn.exec_params("select * from user_token where token = $1 and expires > now()", [token])
    end
    
    def self.changePassword(userid, password)
      update =  <<-SQL
        update users
        set password = $1 
        where id = $2
        SQL
        $conn.exec_params(update, [Password.create(password), userid])
    end

    class << self
      
      include BCrypt

      def get(token)
        row = $conn.exec_params("select * from session where token = $1 and expires > now()", [token])
        puts row
        if !row.num_tuples.zero?
          $conn.exec_params( "update session set expires= now()+ '30 minutes'::interval  where id = $1",  [row[0]['id']])
          User.new(row[0]['userid'], row[0]['username'], row[0]['token'])
        end
      end
      
      def logout(token)
        delete =  <<-SQL
        DELETE FROM session
        WHERE token = $1
        SQL
        $conn.exec_params(delete, [token])
      end
      
      def authenticate(u, p)
        row = $conn.exec_params("select * from users where username = $1 and status='active' and loginAttempts < 5", [u])
        if !row.num_tuples.zero?
          userId = row[0]['id']
          currentPassword = row[0]['password']
          
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
        values (DEFAULT, $1 , $2 , now()+ '30 minutes'::interval, $3)
        SQL
        $conn.exec_params(insert, [id, username, token])
      end 
      
      def resetLoginAttempts(id)
        update =  <<-SQL
          update users
          set loginAttempts = 0
          where id = $1
          SQL
          $conn.exec_params(update, [id]) 
      end 
      
      def increaseLoginAttempts(id)
        update =  <<-SQL
          update users
          set loginAttempts = loginAttempts + 1 
          where id = $1
          SQL
          $conn.exec_params(update, [id])
      end

    end

  end