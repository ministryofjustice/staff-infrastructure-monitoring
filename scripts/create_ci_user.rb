#!/usr/bin/env ruby


require 'net/http'
require 'json'

# curl -u pttp:Puu10rviYsBQSSsg0J7usr29Gs9Kn5LlEg3EYQDebvc= 
# / https://monitoring-alerting.dev.staff.service.justice.gov.uk/api/admin/users 
# / --data-binary '{"name": "test-user", "email": "emma_lc_123@hotmail.com", "login": "test", "password": "test123"}'
# / -H "Content-type: application/json"

def create_ci_user
  grafana_url = "https://monitoring-alerting.dev.staff.service.justice.gov.uk/api/admin/users"
  grafana_admin_username = "pttp"
  grafana_admin_password = "Puu10rviYsBQSSsg0J7usr29Gs9Kn5LlEg3EYQDebvc="

  uri = URI(grafana_url)
  req = Net::HTTP::Post.new(uri)
  req.basic_auth grafana_admin_username, grafana_admin_password

  req.set_form_data(
    'name' => 'test-user',
    'email' => 'emma_lc_123@hotmail.com',
    'login' => 'test',
    'password' => 'test123'
  )

  res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
    http.request(req)
  }

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    puts "Successfully added user"
    JSON.parse(res.body)["id"]
  else
    res.value
  end
end

user_id = create_ci_user()
puts user_id

def assign_admin_permissions_to_ci_user(user_id)
    grafana_url = "https://monitoring-alerting.dev.staff.service.justice.gov.uk/api/admin/users/#{user_id}/permissions"
    grafana_admin_username = "pttp"
    grafana_admin_password = "Puu10rviYsBQSSsg0J7usr29Gs9Kn5LlEg3EYQDebvc="

    uri = URI(grafana_url)
    req = Net::HTTP::Put.new(uri)
    req.basic_auth grafana_admin_username, grafana_admin_password
  
    req.set_form_data(
      'isGrafanaAdmin' => true
    )
  
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
      http.request(req)
    }

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      puts "Successfully updated user permissions"
      puts res.body
    else
      res.value
    end
end

assign_admin_permissions_to_ci_user(user_id)

  