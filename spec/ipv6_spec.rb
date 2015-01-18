require "spec_helper"

describe "stig::ipv6" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
  
  it "creates /etc/sysconfig/network template" do
    expect(chef_run).to create_template("/etc/sysconfig/network").with(
        source: "etc_sysconfig_network.erb",
        owner: "root",
        group: "root",
        mode: 0644
      )
  end
  
  it "creates /etc/sysconfig/network template" do
    expect(chef_run).to create_template("/etc/sysconfig/network").with(
        source: "etc_sysconfig_network.erb",
        owner: "root",
        group: "root",
        mode: 0644
      )
  end
  
  it "creates /etc/modprobe.d/ipv6.conf template" do
    expect(chef_run).to create_template("/etc/modprobe.d/ipv6.conf").with(
        source: "etc_modprobe.d_ipv6.conf.erb",
        owner: "root",
        group: "root",
        mode: 0644
      )
  end
end