require 'spec_helper'

describe Error do

  let(:error) { Error.new("Field name", "Field name is required.") }

  it { error.should respond_to :field_name }
  it { error.field_name.should eq "Field name" }
  it { error.should respond_to :message }
  it { error.message.should eq "Field name is required." }

  describe "deserializing" do
    it "must deserialize to json" do
      error.to_json.should eq '{"field_name":"Field name","message":"Field name is required."}'
    end
  end

end