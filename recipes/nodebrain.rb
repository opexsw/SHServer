#
# Cookbook Name:: SHS-Engine
# Recipe:: nodebrain
#
# Copyright 2016, Opex Software
#
# All rights reserved - Do Not Redistribute
nb_repo = ''
repo_config_dir = ''
repo_name = ''

case node['platform_family']
when 'rhel'
  if node['platform'] == 'redhat'
    nb_repo = 'https://bintray.com/opexsw/nb-rhel/rpm -O bintray-opexsw-nb-rhel.repo'
    repo_config_dir = '/etc/yum.repos.d/'
    repo_name = 'bintray-opexsw-nb-rhel.repo'
  end
  if node['platform'] == 'centos'
    nb_repo = 'https://bintray.com/opexsw/nb-centos/rpm -O bintray-opexsw-nb-centos.repo'
    repo_config_dir = '/etc/yum.repos.d/'
    repo_name = 'bintray-opexsw-nb-centos.repo'
  end
when 'suse'
  nb_repo = 'https://bintray.com/opexsw/nb-suse/rpm -O bintray-opexsw-nb-suse.repo'
  repo_config_dir = '/etc/zypp/repos.d/'
  repo_name = 'bintray-opexsw-nb-suse.repo'
end

# Install wget
package 'wget' do
  action :install
end

# Add Repo
bash 'Add repo' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  wget --no-check-certificate #{nb_repo}
  mv #{repo_name} #{repo_config_dir}
  mkdir /var/log/SHS
  EOH
  not_if { ::File.exist?('/var/log/SHS') }
end

# Install nodebrain
package 'nodebrain' do
  action :install
end
