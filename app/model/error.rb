require 'json'

class Error

  attr_reader :field_name, :message

  def initialize(field_name, message)
    @field_name = field_name
    @message = message
  end

  def to_json(*a)
    {"field_name" => @field_name, "message" => @message}.to_json
  end

end