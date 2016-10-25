#
# Cookbook Name:: litc-glds-shs-client
# Recipe:: serf
#
# Copyright 2016, Opex Software
#
# All rights reserved - Do Not Redistribute
#

remote_file "#{Chef::Config[:file_cache_path]}/serf.zip" do
  source node['serf']['serf_url']
  mode '0755'
  action :create
end

# Install unzip for extracting serf
package 'unzip' do
  action :install
end

execute 'extract serf' do
  command 'unzip serf.zip'
  cwd Chef::Config[:file_cache_path]
  action :run
  not_if { ::File.exist?("#{Chef::Config[:file_cache_path]}/serf") }
end

execute 'move serf file' do
  command "cp -R #{Chef::Config[:file_cache_path]}/serf /usr/local/bin"
  action :run
  not_if { ::File.exist?('/usr/local/bin/serf') }
end

bash 'Create serf log' do
  user 'root'
  code <<-EOH
    mkdir -p /var/log/serf/
    touch /var/log/serf/serf.log
  EOH
  not_if { ::File.exist?('/var/log/serf/serf.log') }
end

# Add serf service
cookbook_file '/etc/init.d/serf' do
  source 'serf_service'
  owner 'root'
  group 'root'
  mode 0755
end
