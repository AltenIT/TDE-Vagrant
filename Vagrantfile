Vagrant.configure("2") do |config|
  config.vm.box = "peru/ubuntu-18.04-desktop-amd64"
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
    # Make sure the network cable is connected when not a default setting:
    vb.customize [
      "modifyvm", :id,
      "--cableconnected1", "on",
    ]
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.cpus = 2
  end
end
# Vagrant.configure("2") do |config|
#   config.vm.provision "bootstrap", type: "shell", run: "once" do |s|
#     s.inline = "echo hello"
#   end
# end
Vagrant.configure("2") do | config |
  config.vm.provision "provision", type: "shell", path: "provision.sh"  
end