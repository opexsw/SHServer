# Cookbook Name:: SHServer
# Recipe:: SHServer
#
# Copyright 2016, Opex Software
#
# All rights reserved - Do Not Redistribute
#
include_recipe 'SHServer::apache'
include_recipe 'SHServer::nodebrain'
include_recipe 'SHServer::serf'
node_ip = node['ipaddress']
node_name = node['hostname']
apache_user = node['SHServer']['apache_user']

bash 'Install PHP 5.6' do
  user 'root'
  code <<-EOH
    rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm
    yum install -y php56w php56w-opcache php56w-xml php56w-mcrypt php56w-gd php56w-devel php56w-mysql php56w-intl php56w-mbstring php56w-bcmath
  EOH
  not_if { ::File.exist?('/usr/bin/php') }
end

# Add PHP configuration
template "#{node['SHServer']['apache_doc_root']}/index.php" do
  source 'index.php.erb'
  variables(
    slim_php_autoloader: node['SHServer']['slim_php_autoloader'],
    project_dir: node['SHServer']['project_dir']
  )
end

cookbook_file "#{node['SHServer']['apache_doc_root']}/.htaccess" do
  source '.htaccess'
  owner apache_user
  group apache_user
  mode 0755
end

# Create serf configuration directory
bash 'Create serf directory' do
  user 'root'
  code <<-EOH
  mkdir /usr/local/serf
  EOH
  not_if { ::File.exist?('/usr/local/serf') }
end

# Copy serf agent configuration
template '/usr/local/serf/shs_server_serf_config.json' do
  source 'shs_server_serf_config.json.erb'
  variables(
    node_ip: node_ip,
    node_name: node_name,
    encrypt_key: node['serf']['encrypt_key']
  )
end

# Start agent service
service 'serf' do
  supports status: true, restart: true, reload: true
  action [:enable, :start]
end

# Install tar
package 'tar' do
  action :install
end

# Install curl
package 'curl' do
  action :install
end

# Deploy jq parser
bash 'Deploy jQ parser' do
  user 'root'
  code <<-EOH
    wget http://stedolan.github.io/jq/download/linux64/jq
    chmod +x jq
    mv jq /usr/bin
  EOH
  not_if { ::File.exist?('/usr/bin/jq') }
end

# Create a directory for server code
directory "#{node['SHServer']['apache_doc_root']}/SHS" do
  owner apache_user
  group apache_user
  recursive true
  action :create
end

# Create a conf directory for configuration files
directory "#{node['SHServer']['apache_doc_root']}/SHS/conf" do
  owner apache_user
  group apache_user
  recursive true
  action :create
end

# Create a bin directory for executing scripts
directory "#{node['SHServer']['apache_doc_root']}/SHS/bin" do
  owner apache_user
  group apache_user
  recursive true
  action :create
end

# configuration file for cron job.
cookbook_file "#{node['SHServer']['apache_doc_root']}/SHS/conf/monitoring_api.properties" do
  source 'monitoring_api.properties'
  owner apache_user
  group apache_user
  mode 0755
end

# configuration file for SHServer.
template "#{node['SHServer']['apache_doc_root']}/SHS/conf/healingscriptconf.ini" do
  source 'healingscriptconf.ini.erb'
  variables(
    user_name: node['SHServer']['hrepo_username'],
    password: node['SHServer']['hrepo_password'],
    repo_url: node['SHServer']['healingscript_repo_url'],
    repo_name: node['SHServer']['healingscript_repo_name']
  )
  mode 0755
end

# cron script
template "#{node['SHServer']['apache_doc_root']}/SHS/bin/pull_nagios_alerts.sh" do
  source 'pull_nagios_alerts.sh.erb'
  variables(
    DOC_ROOT: node['SHServer']['apache_doc_root']
  )
  mode 0755
end

# cron script to run daily and remove the logFiles older than the configured no_of_days
template '/etc/cron.daily/removeOlderLogFiles.sh' do
  source 'removeOlderLogFiles.sh.erb'
  variables(
    NO_OF_DAYS: node['logFiles']['remove_before_no_of_days']
  )
  mode 0755
end

# Install scheduler
package 'cronie' do
  action :install
end

# Schedule a cron job to pull data from nagios in every configured time interval
cron 'Pull nagios alerts' do
  minute '*/5'
  command "#{node['SHServer']['apache_doc_root']}/SHS/bin/pull_nagios_alerts.sh #{node['SHServer']['apache_doc_root']}/SHS/conf/monitoring_api.properties"
end

# Start cron service
service 'crond' do
  action [:start]
end

# Create a directory for healingscripts
directory "#{node['SHServer']['apache_doc_root']}/SHS/repository" do
  owner apache_user
  group apache_user
  action :create
end

# Create a named pipe
execute 'Create named pipe' do
  command "mkfifo #{node['SHServer']['apache_doc_root']}/SHS/trappipe"
  not_if { ::File.exist?("#{node['SHServer']['apache_doc_root']}/SHS/trappipe") }
end

# configuration for rules directory
cookbook_file "#{Chef::Config[:file_cache_path]}/rules.tar.gz" do
  source 'rules.tar.gz'
  action :create
end

# configuration for Readme
cookbook_file "#{node['SHServer']['apache_doc_root']}/SHS/Readme.md" do
  source 'Readme.md'
  action :create
end

# configuration for version file
cookbook_file "#{node['SHServer']['apache_doc_root']}/SHS/version" do
  source 'version'
  action :create
end

# configuration for web directory
cookbook_file "#{Chef::Config[:file_cache_path]}/web.tar.gz" do
  source 'web.tar.gz'
  action :create
end

# configuration for servantscript
cookbook_file "#{Chef::Config[:file_cache_path]}/servantscript.tar.gz" do
  source 'web.tar.gz'
  action :create
end

# Extract servantscript
execute 'extract servantscript' do
  command "tar -xvzf #{Chef::Config[:file_cache_path]}/servantscript.tar.gz -C #{node['SHServer']['apache_doc_root']}/SHS/"
  action :run
  only_if "! [[ -d #{node['SHServer']['apache_doc_root']}/SHS/servantscript.tar.gz ]]"
end

# Extract web directory
execute 'extract web' do
  command "tar -xvzf #{Chef::Config[:file_cache_path]}/web.tar.gz -C #{node['SHServer']['apache_doc_root']}/SHS/"
  action :run
  only_if "! [[ -d #{node['SHServer']['apache_doc_root']}/SHS/web ]]"
end

# Extratc rules directory
execute 'extract rules' do
  command "tar -xvzf #{Chef::Config[:file_cache_path]}/rules.tar.gz -C #{node['SHServer']['apache_doc_root']}/SHS/"
  action :run
  only_if "! [[ -d #{node['SHServer']['apache_doc_root']}/SHS/rules ]]"
end

# Update rule with correct Document Root Value.
execute 'Put DOC_ROOT value in rule' do
  command "sed -i 's/DOC_ROOT/#{node['SHServer']['escaped_apache_doc_root']}/g' #{node['SHServer']['apache_doc_root']}/SHS/rules/healingrules_v2.nb"
  only_if "grep 'DOC_ROOT' #{node['SHServer']['apache_doc_root']}/SHS/rules/healingrules_v2.nb >> /dev/null"
end

# Update rule with correct HealingRepo Name.
execute 'Put REPO_NAME value in rule' do
  command "sed -i 's/REPO_NAME/#{node['SHServer']['healingscript_repo_name']}/g' #{node['SHServer']['apache_doc_root']}/SHS/rules/healingrules_v2.nb"
  only_if "grep 'REPO_NAME' #{node['SHServer']['apache_doc_root']}/SHS/rules/healingrules_v2.nb >> /dev/null"
end

# Disable selinux support.
execute 'Disable SELinux' do
  command "sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config"
  not_if "grep 'SELINUX=disabled' /etc/selinux/config >> /dev/null"
  only_if { ::File.exist?('/etc/selinux/config') }
end

# Execute setenforce command.
execute 'setenforce command' do
  command 'setenforce 0'
  only_if "getenforce | grep 'Enforcing' >> /dev/null"
  only_if { ::File.exist?('/etc/selinux/config') }
end

# Change the ownership of the SHS directory
execute 'chown-apache' do
  command "chown -R #{apache_user}:#{apache_user} #{node['SHServer']['apache_doc_root']}/SHS"
  user 'root'
  action :run
  not_if "stat -c %U #{node['SHServer']['apache_doc_root']}/SHS |grep #{apache_user}"
end

# Install logrotate
package 'logrotate' do
  action :install
end

# LogRotate conf file
template '/var/log/SHS/serverlogrotate.conf' do
  source 'serverlogrotate.conf.erb'
  mode 0755
end

# LogRotate the SHServer serf log file
execute 'LogRotate SHServer serf log file' do
  command 'logrotate -s /var/log/logstatus /var/log/SHS/serverlogrotate.conf'
end

# Start agent service
service 'httpd' do
  action [:start]
end

# creating the shs-rule-engine service
template '/etc/init.d/shs-rule-engine' do
  source 'shs-rule-engine.erb'
  variables(
    apache_root_dir: node['SHServer']['apache_doc_root'],
    rules_file_name: node['SHServer']['rules_file_name']
  )
  mode '0755'
end

# Restart shs-rule-engine service
service 'shs-rule-engine' do
  supports status: true, restart: true, reload: true
  action [:restart]
end

include_recipe 'SHServer::snmptrapd'

# Restart snmp service
service 'snmptrapd' do
  action [:restart]
end
