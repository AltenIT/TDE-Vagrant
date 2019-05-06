Vagrant.configure("2") do |config|
  config.vm.box = "endegraaf/debian8-desktop"
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
    # Make sure the network cable is connected when not a default setting:
    vb.customize [
      "modifyvm", :id,
      "--cableconnected1", "on",
    ]
    # Customize the amount of memory on the VM:
    vb.memory = "4096"
    vb.cpus = 2
  end
  # provision
  config.vm.provision 'shell' do |s|
    s.path = 'provision.sh'
  end
end
