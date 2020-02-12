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
    config.vm.define :test_vm do |test_vm|
        test_vm.vm.box = "peru/ubuntu-18.04-desktop-amd64"
        test_vm.vm.provision "provision", type: "shell", path: "provision.sh"
    end
end

# Vagrant.configure("2") do | config |
#   config.vm.provision "provision", type: "shell", path: "provision.sh"  
# end
