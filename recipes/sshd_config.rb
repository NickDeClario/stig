# Cookbook Name:: stig
# Recipe:: sshd_config
# Author: Ivan Suftin <isuftin@usgs.gov>
#
# Description: Configure SSHd
#
# CIS Benchmark Items
# RHEL6: 6.2.2, 6.2.3, 6.2.5, 6.2.6, 6.2.7, 6.2.8, 6.2.9, 6.2.10, 6.2.13
# CENTOS6: 6.2.2, 6.2.3, 6.2.5, 6.2.6, 6.2.7, 6.2.8, 6.2.9, 6.2.10, 6.2.13
#
# - Set LogLevel to INFO
# - Set Permissions on /etc/ssh/sshd_config
# - Set SSH MaxAuthTries to 4 or Less
# - Set SSH IgnoreRhosts to Yes
# - Set SSH HostbasedAuthentication to No
# - Disable SSH Root Login
# - Set SSH PermitEmptyPasswords to No
# - Do Not Allow Users to Set Environment Options
# - Limit Access via SSH

if node[:stig][:sshd_config][:ignore_rhosts]
  ignore_rhosts = "yes"
else
  ignore_rhosts = "no"
end

if node[:stig][:sshd_config][:host_based_auth]
  host_based_auth = "yes"
else
  host_based_auth = "no"
end

if node[:stig][:sshd_config][:permit_root_login]
  permit_root_login = "yes"
else
  permit_root_login = "no"
end

if node[:stig][:sshd_config][:permit_empty_passwords]
  permit_empty_passwords = "yes"
else
  permit_empty_passwords = "no"
end

if node[:stig][:sshd_config][:allow_users_set_env_opts]
  allow_users_set_env_opts = "yes"
else
  allow_users_set_env_opts = "no"
end

template "/etc/ssh/sshd_config" do
  source "etc_ssh_sshd_config.erb"
  mode 0600
  owner "root"
  group "root"
  variables(
    :log_level => node[:stig][:sshd_config][:log_level],
    :max_auth_tries => node[:stig][:sshd_config][:max_auth_tries],
    :deny_users => node[:stig][:sshd_config][:deny_users],
    :banner_path => node[:stig][:sshd_config][:banner_path],
    :ignore_rhosts => ignore_rhosts,
    :host_based_auth => host_based_auth,
    :permit_root_login => permit_root_login,
    :permit_empty_passwords => permit_empty_passwords,
    :allow_users_set_env_opts => allow_users_set_env_opts
  )
end