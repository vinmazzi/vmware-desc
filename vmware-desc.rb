require 'rbvmomi'

class Connection
	def initialize
		@con = undef
	end

	def set_con(host, user, password)
		con = RbVmomi::VIM.connect(host: host,insecure: true,user: "#{user}@brasil.latam.cea",password: password)
	end

	def get_con
		con
	end
end

class Vm
	def set_vm(vm)
		@vm_def = vm
	end

	def get_vm
		@vm_def
	end
end

class Description 
	def set_desc(con, vm_name, desc)
		rootFolder = con.serviceInstance.content.rootFolder
		dc = rootFolder.childEntity.grep(RbVmomi::VIM::Datacenter).find { |x|  x.name == "CEA"  } 
		vmDef = Vm.new
		cluster = dc.hostFolder.childEntity.grep(RbVmomi::VIM::ClusterComputeResource)
		cluster.find { |c|
			        c.host.find {|h|
					 h.vm.find {|v| 
						 if(v.name.downcase == vm_name.downcase)
							 vmDef.set_vm(v)
						 end
					 }
			        }
		}
		vm = vmDef.get_vm
		conf = RbVmomi::VIM.VirtualMachineConfigSpec(:annotation => desc)
		if(vm)
			vm.ReconfigVM_Task(:spec => conf)
		else
			fail("Vm não encontrada")
		end
	end
end

user = ''
host = ''
password = ''
file = '/tmp/nonotes'

con = Connection.new
renameVm = Description.new
con.set_connection(host, user, password)
connection = con.get_connection

file = File.open('/tmp/nonotes','r').each do |l|
	tmp = l.split(',')
	vm = tmp[0]
	desc = tmp[1]
	renameVm.set_desc(connection, vm, desc)
end
