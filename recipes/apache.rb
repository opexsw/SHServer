#
# Cookbook Name:: SHS-Engine
# Recipe:: apache
#
# Copyright 2016, Opex Software
#
# All rights reserved - Do Not Redistribute

# Install apache on centOS
package 'httpd' do
  action :install
end

# Start apache service
service 'httpd' do
  action [:enable, :start]
end
