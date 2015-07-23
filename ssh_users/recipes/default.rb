group 'opsworks'

#added into create the new group we need
Chef::Log.warn("Creating groups")
create_weddingwire_ng_group

existing_ssh_users = load_existing_ssh_users
existing_ssh_users.each do |id, name|
  unless node[:ssh_users][id]
  Chef::Log.error("Tearing down #{name}")
    teardown_user(name)
  end
end

node[:ssh_users].each_key do |id|
  if existing_ssh_users.has_key?(id)
    unless existing_ssh_users[id] == node[:ssh_users][id][:name]
      new_id = next_free_uid
      rename_user(existing_ssh_users[id], node[:ssh_users][new_id][:name])
      #added in to set the new users to the groups we want
      Chef::Log.warn("Adding user for exisiting SSH user  #{node[:ssh_users][new_id][:name].to_s}")
      add_user_to_default_groups(node[:ssh_users][id])
    end
  else
    new_id = next_free_uid
    Chef::Log.info("Setting up new user with id #{new_id}")
    node.set[:ssh_users][id][:uid] = new_id
    setup_user(node[:ssh_users][id])
    #added in to set the new users to the groups we want
    Chef::Log.warn("Adding user for new SSH user #{node[:ssh_users][new_id][:name].to_s}")
    add_user_to_default_groups(node[:ssh_users][id])
  end
  set_public_key(node[:ssh_users][id])
end

system_sudoer = case node[:platform]
                when 'debian'
                  'admin'
                when 'ubuntu'
                  'ubuntu'
                when 'redhat','centos','fedora','amazon'
                   'ec2-user'
                end

template '/etc/sudoers' do
  backup false
  source 'sudoers.erb'
  owner 'root'
  group 'root'
  mode 0440
  variables :sudoers => node[:sudoers], :system_sudoer => system_sudoer
  only_if { infrastructure_class? 'ec2' }
end

template '/etc/sudoers.d/opsworks' do
  backup false
  source 'sudoers.d.erb'
  owner 'root'
  group 'root'
  mode 0440
  variables :sudoers => node[:sudoers], :system_sudoer => system_sudoer
  not_if { infrastructure_class? 'ec2' }
end
