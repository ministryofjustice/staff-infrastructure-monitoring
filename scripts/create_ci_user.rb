#!/usr/bin/env ruby


require 'net/http'
require 'json'

grafana_url = "https://monitoring-alerting.dev.staff.service.justice.gov.uk/api"
username = "test"

def authenticate_request(req)
  grafana_admin_username = "pttp"
  grafana_admin_password = "Puu10rviYsBQSSsg0J7usr29Gs9Kn5LlEg3EYQDebvc="

  req.basic_auth grafana_admin_username, grafana_admin_password
end

def make_request(req,uri)
  Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
    http.request(req)
  }
end

def check_for_user(grafana_url,username)
  uri = URI("#{grafana_url}/users/lookup?loginOrEmail=#{username}")

  req = Net::HTTP::Get.new(uri)
  authenticate_request(req)

  res = make_request(req,uri)

  res.code != "404"
end

def create_ci_user(grafana_url)
  uri = URI("#{grafana_url}/admin/users")
  req = Net::HTTP::Post.new(uri)
  authenticate_request(req)
  
  req.set_form_data(
    'name' => 'test-user',
    'email' => 'emma_lc_123@hotmail.com',
    'login' => 'test',
    'password' => 'test123'
  )

  res = make_request(req,uri)

  case res
  when Net::HTTPSuccess, Net::HTTPRedirection
    puts "Successfully added user"
    JSON.parse(res.body)["id"]
  else
    res.value
  end
end

def assign_admin_permissions_to_ci_user(grafana_url, user_id)
    uri = URI("#{grafana_url}/org/users/#{user_id}")
    req = Net::HTTP::Patch.new(uri)
    authenticate_request(req)
  
    req.set_form_data(
      'role' => 'Admin'
    )
  
    res = make_request(req,uri)

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      puts "Successfully updated user permissions"
      puts res.body
    else
      res.value
    end
end


# user_id = create_ci_user(grafana_url)
# puts user_id
# assign_admin_permissions_to_ci_user(grafana_url, user_id)

puts check_for_user(grafana_url,username)
