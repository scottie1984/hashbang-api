
class CommentHelper

  def self.toJSON(comments)
    json_new = []
    
    comments.each { |comment|
      
      md5gravatar = Digest::MD5.hexdigest(comment[4])
        
      json_new.push(JSON.parse({
        "id"=> comment[0], 
        "username" => comment[1],
        "comment" => comment[2],
        "datetime" => minutes_in_words(comment[3].to_datetime),
        "gravatar" => md5gravatar
      }.to_json))
    }
    json_new.to_json
  end
  
  def self.minutes_in_words(timestamp)
    minutes = (((Time.now - timestamp).abs)/60).round
    
    return nil if minutes < 0
    
    case minutes
      when 0..4            then 'within 5 minutes'
      when 5..14           then 'within 15 minutes'
      when 15..29          then 'within 30 minutes'
      when 30..59          then 'within 30 minutes'
      when 60..119         then 'over 1 hour ago'
      when 120..239        then 'over 2 hours ago'
      when 240..479        then 'over 4 hours ago'
      when 480..719        then 'over 8 hours ago'
      when 720..1439       then 'over 12 hours ago'
      when 1440..11519     then 'over ' << (minutes/1440).floor.to_s + 'day' + ' ago'
      when 11520..43199    then 'over ' << (minutes/11520).floor.to_s + 'week' + ' ago'
      when 43200..525599   then 'over ' << (minutes/43200).floor.to_s + 'month' + ' ago' 
      else                      'over ' << (minutes/525600).floor.to_s + 'year' + ' ago'
    end
  end

end