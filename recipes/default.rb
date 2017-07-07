#
# Cookbook Name:: node-deploy
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
case node['platform']
  when 'ubuntu', 'debian'
    remote_file '/tmp/setup-nodejs' do
      source 'https://deb.nodesource.com/setup_4.x'
      owner 'root'
      group 'root'
      mode '0755'
      not_if {File.exists?("/tmp/setup-nodejs")}
    end
    bash 'setup-nodejs' do
      guard_interpreter :bash
      code '/tmp/setup-nodejs'
    end
    %w(nodejs git).each do |pkg|
     package pkg
   end
   user "#{node['node-deploy']['app']['user']}" do
     comment 'Web Application user'
   end
   directory "#{node['node-deploy']['app']['deploy_dir']}" do
     owner "#{node['node-deploy']['app']['user']}"
     group "#{node['node-deploy']['app']['user']}"
     mode '0755'
     recursive true
     action :create
   end
   log "#{node['node-deploy']['app']['deploy_dir']}"
   git "#{node['node-deploy']['app']['deploy_dir']}" do
     repository "#{node['node-deploy']['app']['repo']}"
     revision "#{node['node-deploy']['app']['repo']['branch']}"
     user "#{node['node-deploy']['app']['user']}"
     # destination "#{node['node-deploy']['app']['deploy_dir']}"
     action :sync
   end
   if "#{node['node-deploy']['app']['deploy_dir']}"
     path = node['node-deploy']['app']['deploy_dir']
     cmd  = "npm install --#{node['node-deploy']['app']['env']}"
     execute "npm install at #{path}" do
       cwd path
       command cmd
     end
   end
   bash 'install_npm' do
     guard_interpreter :bash
     cwd node['node-deploy']['app']['deploy_dir']
     code 'npm install --"#{node[:node-deploy][:app][:env]}"'
   end

   log "#{node['node-deploy']['app']['conf_file']}"
   template "#{node['node-deploy']['app']['conf_file']}" do
     source 'app.conf.erb'
     variables({
     :port => node['node-deploy']['nginx']['port'],
     :server_name => node['node-deploy']['server']['name'],
     :ip_addr => node['node-deploy']['server']['ip_addr'],
     :app_dir => node['node-deploy']['app']['root_dir'],
     :app_name => node['node-deploy']['app']['name'],
     :startup_file  => node['node-deploy']['passenger']['startup_file']
     })
     mode '0644'
     owner 'root'
     group 'root'
   end
   service 'nginx' do
     action :restart
   end
  when 'redhat', 'centos'
    remote_file '/tmp/setup-nodejs' do
      source "https://rpm.nodesource.com/setup_#{node['node-deploy']['node']['version']}"
      owner 'root'
      group 'root'
      mode '0755'
      not_if {File.exists?("/tmp/setup-nodejs")}
    end
    bash 'setup-nodejs' do
      guard_interpreter :bash
      code '/tmp/setup-nodejs'
    end
     %w(nodejs git).each do |pkg|
      package pkg
    end
    user "#{node['node-deploy']['app']['user']}" do
      comment 'Web Application user'
    end
    directory "#{node['node-deploy']['app']['deploy_dir']}" do
      owner "#{node['node-deploy']['app']['user']}"
      group "#{node['node-deploy']['app']['user']}"
      mode '0755'
      recursive true
      action :create
    end
    log "#{node['node-deploy']['app']['deploy_dir']}"
    git "#{node['node-deploy']['app']['deploy_dir']}" do
      repository "#{node['node-deploy']['app']['repo']}"
      revision "#{node['node-deploy']['app']['repo']['branch']}"
      user "#{node['node-deploy']['app']['user']}"
      # destination "#{node['node-deploy']['app']['deploy_dir']}"
      action :sync
    end
    if "#{node['node-deploy']['app']['deploy_dir']}"
      path = node['node-deploy']['app']['deploy_dir']
      cmd  = "npm install --#{node['node-deploy']['app']['env']}"
      execute "npm install at #{path}" do
        cwd path
        command cmd
      end
    end
    bash 'install_npm' do
      guard_interpreter :bash
      cwd node['node-deploy']['app']['deploy_dir']
      code 'npm install --"#{node[:node-deploy][:app][:env]}"'
    end

    log "#{node['node-deploy']['app']['conf_file']}"
    # Creating application's config file
    template "#{node['node-deploy']['app']['conf_file']}" do
      source 'app.conf.erb'
      variables({
      :port => node['node-deploy']['nginx']['port'],
      :server_name => node['node-deploy']['server']['name'],
      :ip_addr => node['node-deploy']['server']['ip_addr'],
      :app_dir => node['node-deploy']['app']['root_dir'],
      :app_name => node['node-deploy']['app']['name'],
      :startup_file  => node['node-deploy']['passenger']['startup_file']
      })
      mode '0644'
      owner 'root'
      group 'root'
    end
    service 'nginx' do
      action :restart
    end
end
