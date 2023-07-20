IMAGE_NAME = "ubuntu/focal64"
K8S_NAME = "yan-k8s-01"
K8S_VER = "1.23"
CONTAINER_RUNTIME = "containerd"
MASTERS_NUM = 1
MASTERS_CPU = 2
MASTERS_MEM = 2048

NODES_NUM = 3
NODES_CPU = 2
NODES_MEM = 2048

IP_BASE = "192.168.56."

VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
      end


      (1..MASTERS_NUM).each do |i|
        config.vm.define "k8s-m-#{i}" do |master|
            master.vm.box = IMAGE_NAME
            master.vm.network "private_network", ip: "#{IP_BASE}#{i + 10}"
            master.vm.hostname = "k8s-m-#{i}"
            master.vm.provider "virtualbox" do |v|
                v.memory = MASTERS_MEM
                v.cpus = MASTERS_CPU
            end
            master.vm.provision "ansible" do |ansible|
                ansible.playbook = "playbooks/kickstart.yml"
                #Redefine defaults
                ansible.extra_vars = {
                    k8s_cluster_name:       K8S_NAME,
                    kubernetes_role:        "master",
                    k8s_version:            K8S_VER,
                    container_runtime:      CONTAINER_RUNTIME,
                    k8s_master_admin_user:  "vagrant",
                    k8s_master_admin_group: "vagrant",
                    k8s_master_apiserver_advertise_address: "#{IP_BASE}#{i + 10}",
                    k8s_master_node_name: "k8s-m-#{i}",
                    k8s_node_public_ip: "#{IP_BASE}#{i + 10}",
                    k8s_cp_ip: "#{IP_BASE}#{1 + 10}"
                }
            end
            master.vm.provision "shell", path: "playbooks/rook-ceph.sh"
        end
    end

    (1..NODES_NUM).each do |j|
        config.vm.define "k8s-n-#{j}" do |node|
            node.vm.box = IMAGE_NAME
            node.vm.network "private_network", ip: "#{IP_BASE}#{j + 10 + MASTERS_NUM}"
            node.vm.hostname = "k8s-n-#{j}"
            node.vm.provider "virtualbox" do |v|
                unless File.exist?("./k8s-n-#{j}-secondDisk.vdi")
                  v.customize ['createhd', '--filename', "./k8s-n-#{j}-secondDisk.vdi", '--variant', 'Fixed', '--size', 10 * 1024]
                end
                v.memory = NODES_MEM
                v.cpus = NODES_CPU
                v.customize ['storageattach', :id,  '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', "./k8s-n-#{j}-secondDisk.vdi"]
                #v.customize ["modifyvm", :id, "--cpuexecutioncap", "20"]
            end
            node.vm.provision "ansible" do |ansible|
                ansible.playbook = "playbooks/kickstart.yml"
                #Redefine defaults
                ansible.extra_vars = {
                    k8s_cluster_name:     K8S_NAME,
                    kubernetes_role:      "node",
                    k8s_version:            K8S_VER,
                    container_runtime:      CONTAINER_RUNTIME,
                    k8s_node_admin_user:  "vagrant",
                    k8s_node_admin_group: "vagrant",
                    k8s_node_public_ip: "#{IP_BASE}#{j + 10 + MASTERS_NUM}"
                }
            end
        end
    end
end
