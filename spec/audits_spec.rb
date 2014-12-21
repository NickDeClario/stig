require "spec_helper"

describe "stig::audits" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

  before do
    stub_command("test -n \"$(/bin/cat /etc/shadow | /bin/awk -F: '($2 == \"\" )')\"").and_return(true)
  end
  
  before do
    stub_command("test -n \"$(/bin/grep '^+' /etc/passwd)\"").and_return(true)
  end
  
  before do
    stub_command("test -n \"$(/bin/grep '^+' /etc/shadow)\"").and_return(true)
  end
  
  before do
    stub_command("test -n \"$(/bin/grep '^+' /etc/group)\"").and_return(true)
  end
  
  before do
    stub_command("test -n \"$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002)\"").and_return(true)
  end
  
  before do
    stub_command("test -n \"$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser -ls)\"").and_return(true)
  end
  
  before do
    stub_command("test -n \"$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup -ls)\"").and_return(true)
  end
  
  before do
    stub_command("/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0) { print $1 }' | grep -v \"root\"").and_return(true)
  end
  
  it "checks for empty password fields" do
    expect(chef_run).to run_bash("no_empty_passwd_fields").with(
    user: "root",
    code: "for user in $(/bin/cat /etc/shadow | /bin/awk -F: '($2 == \"\")' | cut -d':' -f1 $1);do /usr/bin/passwd -l $user;done"
    )
  end
  
  it "no legacy + entries exist in /etc/passwd" do
    expect(chef_run).to run_bash("no legacy + entries exist in /etc/passwd").with(
    user: "root",
    code: "sed -i '/^+/ d' /etc/passwd"
    )
  end
  
  it "no legacy + entries exist in /etc/shadow" do
    expect(chef_run).to run_bash("no legacy + entries exist in /etc/shadow").with(
    user: "root",
    code: "sed -i '/^+/ d' /etc/shadow"
    )
  end
  
  it "no legacy + entries exist in /etc/group" do
    expect(chef_run).to run_bash("no legacy + entries exist in /etc/group").with(
    user: "root",
    code: "sed -i '/^+/ d' /etc/group"
    )
  end
  
  it "checks for world writable files" do
    expect(chef_run).to run_bash("remove_world_writable_flag_from_files").with(
    user: "root",
    code: "for fn in $(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type f -perm -0002);do chmod o-w $fn;done"
    )
  end
  
  it "checks for unowned files and directories" do
    expect(chef_run).to run_bash("reclaim_ownership_of_orphaned_files_and_dirs").with(
    user: "root",
    code: "for fn in $(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser -ls | awk '{ printf $11\"\\n\" }'); do chown root:root $fn;done"
    )
  end
  
  it "checks for group unowned files and directories" do
    expect(chef_run).to run_bash("find group orphaned files and directories").with(
    user: "root",
    code: "for fn in $(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup -ls | awk '{ printf $11\"\\n\" }'); do chown root:root $fn;done"
    )
  end
  
  it "no UID 0 except root account exists" do
    expect(chef_run).to run_bash("no UID 0 except root account exists").with(
    user: "root",
    code: "for acct in $(/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0) { print $1 }' | grep -v \"root\"); do sed -i \"/^$acct:/ d\" /etc/passwd;done"
    )
  end
  
  it "creates an .audit sub directory in /root" do
    expect(chef_run).to create_directory("/root/.audit").with(
    owner: "root",
    group: "root",
    mode: 0600
    )
  end
  
  it "creates /root/.audit/path_integrity_check.sh file" do
    expect(chef_run).to create_cookbook_file("path_integrity_check.sh").with(
      path: "/root/.audit/path_integrity_check.sh",
      owner: "root",
      group: "root",
      mode: 0700
    )
  end
  
  it "creates /root/.audit/rhosts_check.sh file" do
    expect(chef_run).to create_cookbook_file("rhosts_check.sh").with(
      path: "/root/.audit/rhosts_check.sh",
      owner: "root",
      group: "root",
      mode: 0700
    )
  end
  
  it "creates /root/.audit/check_groups_in_etc_passwd.sh file" do
    expect(chef_run).to create_cookbook_file("check_groups_in_etc_passwd.sh").with(
      path: "/root/.audit/check_groups_in_etc_passwd.sh",
      owner: "root",
      group: "root",
      mode: 0700
    )
  end
  
  it "creates /root/.audit/validate_users_homedirs.sh file" do
    expect(chef_run).to create_cookbook_file("validate_users_homedirs.sh").with(
      path: "/root/.audit/validate_users_homedirs.sh",
      owner: "root",
      group: "root",
      mode: 0700
    )
  end
  
  it "creates /root/.audit/check_duplicate_uid.sh file" do
    expect(chef_run).to create_cookbook_file("check_duplicate_uid.sh").with(
      path: "/root/.audit/check_duplicate_uid.sh",
      owner: "root",
      group: "root",
      mode: 0700
    )
  end
  
  it "creates /root/.audit/check_duplicate_gid.sh file" do
    expect(chef_run).to create_cookbook_file("check_duplicate_gid.sh").with(
      path: "/root/.audit/check_duplicate_gid.sh",
      owner: "root",
      group: "root",
      mode: 0700
    )
  end
  
  it "creates /root/.audit/check_duplicate_usernames.sh file" do
    expect(chef_run).to create_cookbook_file("check_duplicate_usernames.sh").with(
      path: "/root/.audit/check_duplicate_usernames.sh",
      owner: "root",
      group: "root",
      mode: 0700
    )
  end
  
  it "creates /root/.audit/check_duplicate_groupnames.sh file" do
    expect(chef_run).to create_cookbook_file("check_duplicate_groupnames.sh").with(
      path: "/root/.audit/check_duplicate_groupnames.sh",
      owner: "root",
      group: "root",
      mode: 0700
    )
  end
  
end