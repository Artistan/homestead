# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'
require 'yaml'

VAGRANTFILE_API_VERSION ||= "2"
confDir = $confDir ||= File.expand_path(File.dirname(__FILE__))

homesteadYamlPath = confDir + "/Homestead.yaml"
homesteadJsonPath = confDir + "/Homestead.json"
afterScriptPath = confDir + "/after.sh"
privilegedAfterScriptPath = confDir + "/privileged-after.sh"
customizationScriptPath = confDir + "/user-customizations.sh"
aliasesPath = confDir + "/aliases"

if File.exist? homesteadYamlPath then
    settings = YAML::load(File.read(homesteadYamlPath))
elsif File.exist? homesteadJsonPath then
    settings = JSON::parse(File.read(homesteadJsonPath))
else
    abort "Homestead settings file not found in #{confDir}"
end
hostname = settings["hostname"] ||= "homestead"

require File.expand_path(File.dirname(__FILE__) + '/scripts/homestead.rb')

Vagrant.require_version '>= 2.1.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # https://github.com/phinze/vagrant-host-shell
    config.vm.provision :host_shell do |host_shell|
        host_shell.inline = './system-before.sh ' + hostname + ' ' + ARGV[0]
    end

    if File.exist? aliasesPath then
        config.vm.provision "file", source: aliasesPath, destination: "/tmp/bash_aliases"
        config.vm.provision "shell" do |s|
            s.inline = "awk '{ sub(\"\r$\", \"\"); print }' /tmp/bash_aliases > /home/vagrant/.bash_aliases"
        end
    end

    Homestead.configure(config, settings)

    if File.exist? afterScriptPath then
        config.vm.provision "shell", path: afterScriptPath, privileged: false, keep_color: true
    end

    if File.exist? privilegedAfterScriptPath then
        config.vm.provision "shell", path: privilegedAfterScriptPath, privileged: true, keep_color: true
    end

    config.vm.provision :host_shell do |host_shell|
        host_shell.inline = './system-after.sh ' + hostname + ' ' + ARGV[0]
    end

    if File.exist? customizationScriptPath then
        config.vm.provision "shell", path: customizationScriptPath, privileged: false, keep_color: true
    end

    if Vagrant.has_plugin?('vagrant-hostsupdater')
        config.hostsupdater.aliases = settings['sites'].map { |site| site['map'] }
    elsif Vagrant.has_plugin?('vagrant-hostmanager')
        config.hostmanager.enabled = true
        config.hostmanager.manage_host = true
        config.hostmanager.aliases = settings['sites'].map { |site| site['map'] }
    end
end

# https://superuser.com/questions/701735/run-script-on-host-machine-during-vagrant-up
system('./system-destroy.sh ' + hostname + ' ' + ARGV[0])

