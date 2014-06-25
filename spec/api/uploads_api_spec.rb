require 'spec_helper'

$db = SQLite3::Database.open 'hashbang_test.db'
$upload_dir = 'spec/uploads'

$OUTER_APP = Rack::Builder.parse_file('config.ru').first
$upload_count = 2

describe SocialChallenges::UploadAPI, :type => :feature do

  include Rack::Test::Methods
  include Warden::Test::Helpers

  after(:each) do
    post '/auth/logout', {'token' => @token}
  end

  before(:each) do
    post '/auth/login', {'username' => 'cat_lover1990', 'password' => '12Password12'}
    @token = JSON.parse(last_response.body)['token']
  end

  let(:app) { $OUTER_APP }

  describe "API get endpoints" do
    it "should get all uploads, count = #{$upload_count}" do
      get '/upload/all'
      last_response.status.should == 200
      response = JSON.parse(last_response.body)
      (response.instance_of? Array).should be_true
      response.count.should eq $upload_count
    end
    it "should get a single upload" do
      get '/upload/1'
      last_response.status.should == 200
      last_response.body.should eq "{\"id\":1,\"type\":\"image/jpeg\",\"file_name\":\"http://localhost:9292/upload/1/download\",\"original_file_name\":\"original_cat.jpg\",\"file_name_thumb\":\"http://localhost:9292/upload/1/download/thumb\",\"file_name_medium\":\"http://localhost:9292/upload/1/download/medium\",\"userid\":\"cat_lover1990\",\"upload_datetime\":\"2014-05-20 22:21:43 +0100\",\"overallScore\":2,\"numOfRatings\":3,\"title\":\"The amazing cat\",\"description\":\"This can is amazing\",\"tags\":[\"tag1\",\"tag3\"],\"gravatar\":\"357a20e8c56e69d6f9734d23ef9517e8\"}"
      response = JSON.parse(last_response.body)
      (response.instance_of? Hash).should be_true
    end
    it "should get a single uploaded file" do
      get '/upload/1/download'
      last_response.status.should == 200
      last_response["Content-type"].should eq "image/jpeg"
    end
    it "should return a 404" do
      get '/upload/999'
      last_response.status.should == 404
    end
  end

  describe "API post endpoints" do
    it "should error 403 with 4 errors" do
      post '/upload/add', {'usertoken' => '', 'title' => '', 'tags' => ''}
      last_response.status.should == 403
      last_response.body.should eq "{\"error\":[{\"field_name\":\"user_token\",\"message\":\"The userid field is required\"},{\"field_name\":\"title\",\"message\":\"The title field is required\"},{\"field_name\":\"tags\",\"message\":\"At least one tag is required\"}]}"
      response = JSON.parse(last_response.body)
      (response.instance_of? Hash).should be_true
      response['error'].count.should eq 3
      
    end
    it "should error 403 with usertoken error" do
      post '/upload/add', {'usertoken' => '', 'title' => 'the title', 'tags' => 'some,tag', "image_file" => Rack::Test::UploadedFile.new("#{$upload_dir}/cat.jpg")}
      last_response.status.should == 403
      last_response.body.should eq "{\"error\":[{\"field_name\":\"user_token\",\"message\":\"The userid field is required\"}]}"
      response = JSON.parse(last_response.body)
      (response.instance_of? Hash).should be_true
      response['error'].count.should eq 1
    end
    it "should error 403 with title error" do
      post '/upload/add', {'usertoken' => 'invalid-token', 'title' => '', 'tags' => 'some,tag', "image_file" => Rack::Test::UploadedFile.new("#{$upload_dir}/cat.jpg")}
      last_response.status.should == 403
      last_response.body.should eq "{\"error\":[{\"field_name\":\"title\",\"message\":\"The title field is required\"}]}"
      response = JSON.parse(last_response.body)
      (response.instance_of? Hash).should be_true
      response['error'].count.should eq 1
    end
    it "should error 403 with tags error" do
      post '/upload/add', {'usertoken' => 'invalid-token', 'title' => 'the title', 'tags' => '', "image_file" => Rack::Test::UploadedFile.new("#{$upload_dir}/cat.jpg")}
      last_response.status.should == 403
      last_response.body.should eq "{\"error\":[{\"field_name\":\"tags\",\"message\":\"At least one tag is required\"}]}"
      response = JSON.parse(last_response.body)
      (response.instance_of? Hash).should be_true
      response['error'].count.should eq 1
    end
    it "should error 401" do
      post '/upload/add', {'usertoken' => 'invalid-token', 'title' => 'the title', 'tags' => 'some,tag', "image_file" => Rack::Test::UploadedFile.new("#{$upload_dir}/cat.jpg")}
      last_response.status.should == 401
      last_response.body.should eq "{\"error\":\"Unauthorized\"}"
      response = JSON.parse(last_response.body)
      (response.instance_of? Hash).should be_true
    end
    it "should add an upload" do
      post '/upload/add', {'usertoken' => @token, 'title' => 'the title', 'tags' => 'some,tag', "type" => "image", "image_file" => Rack::Test::UploadedFile.new("#{$upload_dir}/cat.jpg")}
      last_response.status.should == 201
      last_response.body.should eq "3"
      $upload_count+=1
    end
  end

end