#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load

## Variables from param store
grafana_url = ENV['TF_VAR_grafana_url'] + '/api'

def authenticate_request(req)
  grafana_admin_username = ENV['TF_VAR_grafana_admin_username']
  grafana_admin_password = ENV['TF_VAR_grafana_admin_password']

  req.basic_auth grafana_admin_username, grafana_admin_password
end

def make_request(req,uri)
  Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) {|http|
    http.request(req)
  }
end

def ci_user_exists?(grafana_url)
  username = ENV['TF_VAR_ci_user_login']
  uri = URI("#{grafana_url}/users/lookup?loginOrEmail=#{username}")

  req = Net::HTTP::Get.new(uri)
  authenticate_request(req)

  res = make_request(req,uri)

  res.code != "404"
end

def create_ci_user(grafana_url)
  uri = URI("#{grafana_url}/admin/users")
  req = Net::HTTP::Post.new(uri)
  ci_user_login = ENV['TF_VAR_ci_user_login']
  ci_user_password = ENV['TF_VAR_ci_user_password']
  authenticate_request(req)
  
  req.set_form_data(
    'name' => ci_user_login,
    'email' => 'ci@staff.service.justice.gov.uk',
    'login' => ci_user_login,
    'password' => ci_user_password
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
    else
      res.value
    end
end

if ci_user_exists?(grafana_url) == false then
  puts "no user created, creating CI user"
  user_id = create_ci_user(grafana_url)
  assign_admin_permissions_to_ci_user(grafana_url, user_id)

else 
  puts "user already created, exiting..." 

end

  
