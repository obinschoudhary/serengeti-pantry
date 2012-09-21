#
# Cookbook Name:: hbase
# Recipe::        master
#

#
#   Portions Copyright (c) 2012 VMware, Inc. All Rights Reserved.
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

include_recipe "hbase"

%w[ hbase-master ].each do |conf_file|
  template "/etc/init.d/#{conf_file}" do
    owner "root"
    mode "0755"
    source "#{conf_file}.erb"
  end
end

# when starting HBase Master daemon, it requires at least 1 datanode to replicate hbase.version
wait_for_datanodes

# Register with cluster_service_discovery
provide_service node[:hbase][:master_service_registry_name]

# Launch service
set_bootstrap_action(ACTION_START_SERVICE, node[:hbase][:master_service_name])
service node[:hbase][:master_service_name] do
  action [ :enable, :start ]
  supports :status => true, :restart => true

  subscribes :restart, resources("template[/etc/hbase/conf/hbase-site.xml]"), :delayed
  subscribes :restart, resources("template[/etc/hbase/conf/hbase-env.sh]"), :delayed
  notifies :create, resources("ruby_block[#{node[:hbase][:master_service_name]}]"), :immediately
end
