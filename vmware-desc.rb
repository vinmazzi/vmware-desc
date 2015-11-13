require 'rbvmomi'

class Connection
	def initialize
		@con = nil 
	end

	def set_con(host, user, password)
		@con = RbVmomi::VIM.connect(host: host,insecure: true,user: "#{user}@brasil.latam.cea",password: password)
	end

	def get_con
		@con
	end
end

class Vm
	def vm_obj=(vm)
		@vm = vm
	end

	def vm_obj
		@vm
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
							 vmDef.vm_obj = v
						 end
					 }
			        }
		}
		vm = vmDef.vm_obj
		conf = RbVmomi::VIM.VirtualMachineConfigSpec(:annotation => desc)
		if(vm)
			puts("Configurando #{vm.name} com a descrição: '#{desc}'.")
			vm.ReconfigVM_Task(:spec => conf)
		else
			fail("Vm: #{vm.name} não encontrada\n Não foi possivel configurar a descrição '#{desc}'")
		end
	end
end

user = ''
host = ''
password = ''
file = '/tmp/nonotes'

con = Connection.new
renameVm = Description.new
con.set_con(host, user, password)
connection = con.get_con

file = File.open(file,'r').each do |l|
	tmp = l.split(',')
	vm = tmp[0]
	desc = tmp[1]
	renameVm.set_desc(connection, vm, desc)
end
