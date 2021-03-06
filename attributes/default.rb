# Attributes specific to the self healing server
default['SHServer']['pull_req_time'] = "5"
default['SHServer']['healingscript_repo_name'] = 'Self-Healing-Script'
default['SHServer']['healingscript_repo_url'] = 'github.wdf.sap.corp/GLDS-SM/Self-Healing-Script.git'
default['SHServer']['hrepo_username'] = ''
default['SHServer']['hrepo_password'] = ''
default['SHServer']['slim_php_autoloader'] = '/var/www/html/SHS/web/vendor/autoload.php'
default['SHServer']['project_dir'] = '/var/www/html/SHS/web'
default['SHServer']['rules_file_name'] = 'healingrules_v2.nb'
default['SHServer']['apache_doc_root'] = '/var/www/html'
default['SHServer']['escaped_apache_doc_root'] = '\\/var\\/www\\/html'
default['SHServer']['webserver_service_name'] = 'httpd'
default['SHServer']['apache_user'] = 'apache'
default['SHServer']['cron_pkg_name'] = 'cronie'

# Attributes specific to log rotation on server/client
default['logrotate']['filesize'] = '1M'
default['logrotate']['num_of_file_rotation'] = '4'
default['logFiles']['remove_before_no_of_days'] = '7'

# Attributes specific to serf installation on server/client
default['serf']['serf_url'] = 'https://releases.hashicorp.com/serf/0.7.0/serf_0.7.0_linux_amd64.zip'
default['serf']['encrypt_key'] = 'OKo8QmHU5SoLcdVGWARt5A=='

# NOTE: Below attributes are no longer used with the fetch approach.
# They are specific to the snmp approach. DO NOT CHANGE.
default['shs-nagios']['dir'] = '/etc/nagios/conf.d'
default['snmptrapd']['engineid'] = '0x8000000001020304'
default['snmptrapd']['username'] = 'shsuser'
default['snmptrapd']['password'] = 'Password4snmp'
default['snmptrapd']['snmptraphandler'] = '/var/www/html/SHS/traphandle.sh'
