module Parser

  def self.parse_uploads(file, object)
    uploads = []
    CSV.foreach(file, :headers => true, header_converters: :symbol) do |csv_obj|
      uploads << object.new(csv_obj.field(:type), csv_obj.field(:file_name), csv_obj.field(:original_file_name), csv_obj.field(:userid), csv_obj.field(:title), csv_obj.field(:description), csv_obj.field(:upload_datetime), csv_obj.field(:id), csv_obj.field(:overallscore), csv_obj.field(:numofratings), csv_obj.field(:averagescore))
    end
    uploads
  end

  def self.parse_tags(file, object)
    tags = []
    CSV.foreach(file, :headers => true, header_converters: :symbol) do |csv_obj|
      tags << object.new(csv_obj.field(:tagname), csv_obj.field(:userid), csv_obj.field(:type), csv_obj.field(:id), csv_obj.field(:tag_datetime), csv_obj.field(:numofobjects))
    end
    tags
  end

  def self.parse_tag_objects(file)
    tag_objects = []
    CSV.foreach(file, :headers => true, header_converters: :symbol) do |csv_obj|
      tag_objects << { "id" => csv_obj.field(:id).to_i, "objectid" => csv_obj.field(:objectid).to_i, "tagid" => csv_obj.field(:tagid).to_i, "tag_datetime" => csv_obj.field(:tag_datetime) }
    end
    tag_objects
  end

end