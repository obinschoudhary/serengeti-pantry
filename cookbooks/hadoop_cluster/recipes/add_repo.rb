#
# Cookbook Name:: hadoop_cluster
# Recipe::        add_repo
#

#
#   Copyright (c) 2012 VMware, Inc. All Rights Reserved.
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

case node[:platform]
when 'centos'
  if node[:disable_external_yum_repo] then
    directory '/etc/yum.repos.d/backup' do
      mode "0755"
    end
    execute 'disable all external yum repos' do
      command 'mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/'
      ignore_failure true # in case no file found
    end
  else
    execute 'enable all external yum repos' do
      only_if {File.exists?('/etc/yum.repos.d/backup')}
      command 'mv -f /etc/yum.repos.d/backup/*.repo /etc/yum.repos.d/'
      ignore_failure true
    end
  end

  yum_repos = node[:yum_repos] || []
  yum_repos.each do |yum_repo|
    file = "/etc/yum.repos.d/#{::File.basename(yum_repo)}"
    remote_file file do
      source yum_repo
      mode "0644"
    end
  end

  execute 'clean up all yum cache to rebuild package index' do
    command 'yum clean all'
  end
end
