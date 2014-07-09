require 'grape'
require 'rack/contrib'
require 'builder'
require 'yaml'

require_relative './../repository/user_repository'
require_relative './../repository/tag_repository'

module SocialChallenges

  class SitemapAPI < Grape::API
    
    CONFIG = YAML.load_file("./config/config.yml") unless defined? CONFIG

    format :xml

    get '/get' do
      xml = Builder::XmlMarkup.new( :indent => 2 )
      xml.instruct! :xml, :encoding => "UTF-8"
      tags = TagRepository.all('tag')
      xml.urlset(:xmlns=>'http://www.sitemaps.org/schemas/sitemap/0.9') do |p|
        
      tags.each { |tag |
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}/#!/rate/tag/#{tag['tagname']}"
        }
      }
      end
      xml
    end

  end

end