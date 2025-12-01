class axi_agent extends uvm_agent;
`uvm_component_utils(axi_agent)
function new(string name = "axi_agent", uvm_component parent)
    super.new(name,parent);
endfunction

axi_sqr sqr;
axi_drv drv;
axi_mon mon;

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = axi_sqr::type_id::create("sqr",this);
    drv = axi_drv::type_id::create("drv",this);
    mon = axi_mon::type_id::create("mon",this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
endfunction
endclass
