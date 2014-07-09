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
      users = TagRepository.all('user')
      xml.urlset(:xmlns=>'http://www.sitemaps.org/schemas/sitemap/0.9') do |p|
        
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}"
        }
        
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}/#!/recent"
        }
        
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}/#!/random"
        }
        
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}/#!/tagsearch"
        }
        
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}/#!/feedback"
        }
        
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}/#!/signup"
        }
        
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}/#!/login"
        }
        
        p.url {
          p.loc "http://#{CONFIG['frontend_url']}/#!/upload"
        }
        
        tags.each { |tag |
          p.url {
            p.loc "http://#{CONFIG['frontend_url']}/#!/rate/tag/#{tag['tagname']}"
          }
        }
        
        users.each { |user |
          p.url {
            p.loc "http://#{CONFIG['frontend_url']}/#!/rate/user/#{user['tagname']}"
          }
        }
      end
      xml
    end

  end

end