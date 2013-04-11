#
# Cookbook Name:: dovecot
# Recipe:: default
#
# Copyright 2013, Malte Swart
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

dovecotpkg = value_for_platform_family(
  ["rhel", "fedora", "suse"] => "dovecot",
   "debian" => "dovecot-core"
)

package dovecotpkg

service 'dovecot' do
  supports :status => true, :restart => true, :reload => true
  action :enable
end

case node['platform_family']
when "rhel", "fedora", "suse"
  template '/etc/dovecot/dovecot.conf' do 
    source 'dovecot.conf.erb'
    mode 0644
    owner 'root'
    group 'root'
  end
when "debian"
  # generate main.cf
  config = Dovecot::Config.new(node['dovecot'].to_hash)
  
  # write main.cf
file ::File.join(node['dovecot']['_base_dir'], 'dovecot.conf') do
    content config.content
    user 'root'
    group 0
    mode 00644
    notifies :reload, "service[dovecot]"
  end
end

file "/var/spool/mail/#{node['postfix']['catch-all']['localuser']}" do
  owner node['postfix']['catch-all']['localuser']
  mode 0600
  action :create
end

# start service
service 'dovecot' do
  action :start
end
