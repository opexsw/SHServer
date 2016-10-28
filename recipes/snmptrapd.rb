#
# Cookbook Name:: litc-glds-shs-server
# Recipe:: snmptrapd
#
# Copyright 2016, Opex Software
#
# All rights reserved - Do Not Redistribute

# Install net-snmp-utils
package 'net-snmp' do
  options '-y'
  action :install
end

# Install net-snmp-utils
package 'net-snmp-libs' do
  options '-y'
  action :install
end

# Install net-snmp-utils
package 'net-snmp-utils' do
  options '-y'
  action :install
end

# Add snmptraphandler script
cookbook_file "#{node['SHServer']['apache_doc_root']}/SHS/traphandle.sh" do
  source 'snmptraphandler.sh'
  owner 'root'
  group 'root'
  mode 0755
end

# Copy serf handler to the machine
template '/etc/snmp/snmptrapd.conf' do
  source 'snmptrapd.conf.erb'
  owner 'root'
  group 'root'
  mode 0755
end

# Start snmp service
service 'snmptrapd' do
  action [:enable, :start]
end
