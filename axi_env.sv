class axi_env extends uvm_env;
`uvm_component_utils(axi_env)
function new(string name = "", uvm_component parent);
    super.new(name, parent);
endfunction
axi_agent agt;
axi_sbd sbd;
axi_cov cov;
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = axi_agent::type_id::create("agt",this);
    sbd = axi_sbd::type_id::create("sbd",this);
    cov = axi_cov::type_id::create("cov",this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    // Connect all 5 monitor analysis ports to scoreboard
    agt.mon.aw_ap_port.connect(sbd.aw_ae_port);  // Write Address
    agt.mon.w_ap_port.connect(sbd.w_ae_port);    // Write Data
    agt.mon.b_ap_port.connect(sbd.b_ae_port);    // Write Response
    agt.mon.ar_ap_port.connect(sbd.ar_ae_port);  // Read Address
    agt.mon.r_ap_port.connect(sbd.r_ae_port);    // Read Data
    
    // Connect all 5 monitor analysis ports to coverage
    agt.mon.aw_ap_port.connect(cov.aw_ae_port);  // Write Address
    agt.mon.w_ap_port.connect(cov.w_ae_port);    // Write Data
    agt.mon.b_ap_port.connect(cov.b_ae_port);    // Write Response
    agt.mon.ar_ap_port.connect(cov.ar_ae_port);  // Read Address
    agt.mon.r_ap_port.connect(cov.r_ae_port);    // Read Data
endfunction
endclass
