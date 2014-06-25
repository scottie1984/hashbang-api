require 'spec_helper'

describe Uploadmodel do

  let(:time_now) { Time.now.to_s }
  let(:tags) { [Tag.new('tag1', 1), Tag.new('tag2', 1), Tag.new('tag3', 1)] }
  let(:upload) { Uploadmodel.new('image', 'file_name.jpg', 'original_file_name.jpg', 1, 'The title', 'The description', time_now) }
  before { upload.tags = tags }

  it { upload.should respond_to :upload_datetime }
  it { upload.upload_datetime.should eq time_now }
  it { upload.should respond_to :type }
  it { upload.type.should eq 'image' }
  it { upload.should respond_to :file_name }
  it { upload.file_name.should eq 'file_name.jpg' }
  it { upload.should respond_to :original_file_name }
  it { upload.original_file_name.should eq 'original_file_name.jpg' }
  it { upload.should respond_to :userid }
  it { upload.userid.should eq 1 }
  it { upload.should respond_to :title }
  it { upload.title.should eq 'The title' }
  it { upload.should respond_to :description }
  it { upload.description.should eq 'The description' }

  describe "deserializing" do
    it "must deserialize to json" do
      upload.to_json.should eq '{"id":null,"type":"image","file_name":"http://localhost:9292/upload//download","original_file_name":"original_file_name.jpg","file_name_thumb":"http://localhost:9292/upload//download/thumb","file_name_medium":"http://localhost:9292/upload//download/medium","userid":1,"upload_datetime":"'+time_now+'","overallScore":0,"numOfRatings":0,"title":"The title","description":"The description","tags":["tag1","tag2","tag3"],"gravatar":"d41d8cd98f00b204e9800998ecf8427e"}'
    end
  end

end