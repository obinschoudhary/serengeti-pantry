#
# Cookbook Name:: hadoop_cluster
# Recipe::        datanode
#

#
# Copyright 2009, Opscode, Inc.
# Portions Copyright (c) 2012 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "hadoop_cluster"

# Install
hadoop_package node[:hadoop][:packages][:datanode][:name]

# Register with cluster_service_discovery
service_registry_name = "#{node[:cluster_name]}-#{node[:hadoop][:datanode_service_name]}"
ruby_block service_registry_name do
  action :nothing
  block do
    provide_service(service_registry_name)
  end
end

# Launch Service
set_bootstrap_action(ACTION_START_SERVICE, node[:hadoop][:datanode_service_name])
service "#{node[:hadoop][:datanode_service_name]}" do
  action [ :enable, :start ]
  supports :status => true, :restart => true

  subscribes :restart, resources("template[/etc/hadoop/conf/core-site.xml]"), :delayed
  subscribes :restart, resources("template[/etc/hadoop/conf/hdfs-site.xml]"), :delayed
  subscribes :restart, resources("template[/etc/hadoop/conf/hadoop-env.sh]"), :delayed
  subscribes :restart, resources("template[/etc/hadoop/conf/log4j.properties]"), :delayed
  notifies :create, resources("ruby_block[#{node[:hadoop][:datanode_service_name]}]"), :immediately
  notifies :create, resources("ruby_block[#{service_registry_name}]"), :immediately
end

