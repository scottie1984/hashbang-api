require 'spec_helper'

describe Tag do

  let(:tag) { Tag.new("Tag name", 1, 2) }

  it { tag.should respond_to :tagName }
  it { tag.tagName.should eq "Tag name" }
  it { tag.should respond_to :userId }
  it { tag.userId.should eq 1 }
  it { tag.should respond_to :id }
  it { tag.id.should eq 2 }

  describe "deserializing" do
    it "must deserialize to json" do
      tag.to_json.should eq '"Tag name"'
    end
  end

end