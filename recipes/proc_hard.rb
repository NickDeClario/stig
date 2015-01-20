# Cookbook Name:: stig
# Recipe:: proc_hard
# Author: David Blodgett <dblodgett@usgs.gov>
#
# Description: Sets a few policies 
#
# TODO- This recipe should probably be refactored into separate recipes for the 1.x.x and 4.x.x items
#
# CIS Benchmark Items
# RHEL6:  1.7.1, 1.7.2, 1.7.3, 4.1.1, 4.1.2, 4.2.2, 4.2.3, 4.2.4, 4.2.7, 4.4.2.2
# CENTOS6: 1.6.1, 1.6.2, 1.6.3, 5.1.1, 5.1.2, 5.2.2, 5.2.3, 5.2.4, 5.2.7, 5.4.1.2
#
# - Restrict Core Dumps
# - Configure ExecShield
# - Enable Randomized Virtual Memory Region Placement
# - Disable IP Forwarding
# - Disable Send Packet Redirects
# - Disable ICMP Redirect Acceptance
# - Disable Secure ICMP Redirect Acceptance
# - Log Suspicious Packets
# - Enable RFC-recommended Source Route Validation
# - Disable IPv6 Redirect Acceptance

template "/etc/security/limits.conf" do
  source "limits.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

if node["stig"]["network"]["ip_forwarding"]
  ip_forwarding = 1
else
  ip_forwarding = 0
end

if node["stig"]["network"]["packet_redirects"]
  send_redirects = 1
else
  send_redirects = 0
end

if node["stig"]["network"]["icmp_redirect_accept"]
  icmp_redirect_accept = 1
else
  icmp_redirect_accept = 0
end

if node["stig"]["network"]["log_suspicious_packets"]
  log_suspicious_packets = 1
else
  log_suspicious_packets = 0
end

if node["stig"]["network"]["rfc_source_route_validation"]
  rfc_source_route_validation = 1
else
  rfc_source_route_validation = 0
end

if node["stig"]["network"]["ipv6_redirect_accept"]
  ipv6_redirect_accept = 1
else
  ipv6_redirect_accept = 0
end

if node["stig"]["network"]["icmp_all_secure_redirect_accept"]
  icmp_all_secure_redirect_accept = 1
else
  icmp_all_secure_redirect_accept = 0
end

template "/etc/sysctl.conf" do
  source "sysctl.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :ip_forwarding => ip_forwarding,
    :send_redirects => send_redirects,
    :icmp_redirect_accept => icmp_redirect_accept,
    :log_suspicious_packets => log_suspicious_packets,
    :rfc_source_route_validation => rfc_source_route_validation,
    :ipv6_redirect_accept => ipv6_redirect_accept,
    :icmp_all_secure_redirect_accept => icmp_all_secure_redirect_accept
    )
  notifies :run, "execute[sysctl_ip_forward]", :immediately
  notifies :run, "execute[sysctl_send_redirects]", :immediately
  notifies :run, "execute[sysctl_icmp_redirect_accept]", :immediately
  notifies :run, "execute[sysctl_icmp_secure_redirect_accept]", :immediately
  notifies :run, "execute[sysctl_log_suspicious_packets]", :immediately
  notifies :run, "execute[sysctl_rfc_source_route_validation]", :immediately
  notifies :run, "execute[sysctl_ipv4_flush]", :immediately
end

execute "sysctl_ip_forward" do
  user "root"
  command "/sbin/sysctl -w net.ipv4.ip_forward=#{ip_forwarding}"
  action :nothing
end

execute "sysctl_send_redirects" do
  user "root"
  command "/sbin/sysctl -w net.ipv4.conf.all.send_redirects=#{send_redirects}; /sbin/sysctl -w net.ipv4.conf.default.send_redirects=#{send_redirects}"
  action :nothing
end

execute "sysctl_icmp_redirect_accept" do
  user "root"
  command "/sbin/sysctl -w net.ipv4.conf.all.accept_redirects=#{icmp_redirect_accept}; /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=#{icmp_redirect_accept}"
  action :nothing
end

execute "sysctl_icmp_secure_redirect_accept" do
  user "root"
  command "/sbin/sysctl -w net.ipv4.conf.all.secure_redirects=#{icmp_all_secure_redirect_accept}; /sbin/sysctl -w net.ipv4.conf.default.secure_redirects=#{icmp_all_secure_redirect_accept}"
  action :nothing
end

execute "sysctl_log_suspicious_packets" do
  user "root"
  command "/sbin/sysctl -w net.ipv4.conf.all.log_martians=#{log_suspicious_packets}; /sbin/sysctl -w net.ipv4.conf.all.log_martians=#{log_suspicious_packets}"
  action :nothing
end

execute "sysctl_rfc_source_route_validation" do
  user "root"
  command "/sbin/sysctl -w net.ipv4.conf.all.rp_filter=#{rfc_source_route_validation}; /sbin/sysctl -w net.ipv4.conf.default.rp_filter=#{rfc_source_route_validation}"
  action :nothing
end

execute "sysctl_ipv6_redirect_accept" do
  user "root"
  command "/sbin/sysctl -w net.ipv6.conf.default.accept_redirects=#{ipv6_redirect_accept}; /sbin/sysctl -w net.ipv6.route.flush=#{ipv6_redirect_accept}"
  action :nothing
end

execute "sysctl_ipv4_flush" do
  user "root"
  command "/sbin/sysctl -w net.ipv4.route.flush=1"
  action :nothing
end
