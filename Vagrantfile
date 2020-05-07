# Vagrant.configure("2") do |config|
#   config.vm.box = "peru/ubuntu-18.04-desktop-amd64"
#   config.vm.provider "virtualbox" do |vb|
#     vb.gui = false
#     vb.customize [
#       "modifyvm", :id,
#       "--cableconnected1", "on",
#     ]
#     vb.memory = "4096"
#     vb.cpus = 2
#   end
# end
Vagrant.configure("2") do |config|
    config.vm.define :test_dev_vm do |test_dev_vm|
        test_dev_vm.vm.box = "peru/ubuntu-18.04-desktop-amd64"
    end
    config.vm.provision "shell", path: "./provision-base.sh" #do not remove base!
    #config.vm.provision "shell", path: "./provision-tomcat-jenkins.sh"
	config.vm.provision "shell", path: "./provision-idea.sh"
    #config.vm.provision "shell", path: "./provision-misc.sh"
end

