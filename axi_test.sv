class axi_test extends uvm_test;
`uvm_component_utils(axi_test)
function new(string name = "axi_test", uvm_component parent);
    super.new(name,parent);
endfunction
axi_env env;
axi_seq seq;
function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    env = axi_env::type_id::create("env",this);
    seq = axi_wr_rd_seq::type_id::create("seq",this);
endfunction

task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.agt.sqr);
    phase.phase_done.set_drain_time(this, 100);
    phase.drop_objection(this);
endtask

endclass
