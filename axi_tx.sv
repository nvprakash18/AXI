class axi_seq_item extends uvm_sequence_item;
typedef enum bit[2:0] {WR, RD, WR_RD} status_e;
rand status_e status;
//axi wr control channel - RANDOMIZED (inputs to DUT)
rand logic [tag_length-1:0] awid;
rand logic [addr_width-1:0] awaddr;
rand logic [3:0] awlen;
rand logic [2:0] awsize;
rand logic [1:0] awburst;
rand logic [1:0] awlock;
rand logic [3:0] awcache;
rand logic [2:0] awprot;
//axi wr data channel - RANDOMIZED (inputs to DUT)
rand logic [tag_length-1:0] wid;
rand logic [data_width-1:0] wdata[$];
rand logic [3:0] wstrb;
rand logic wlast;
//axi wr resp channel - NOT RANDOMIZED (outputs from DUT)
logic [tag_length-1:0] bid;
logic [1:0] bresp;
//axi read control channel - RANDOMIZED (inputs to DUT)
rand logic [tag_length-1:0] arid;
rand logic [addr_width-1:0] araddr;
rand logic [3:0] arlen;
rand logic [2:0] arsize;
rand logic [1:0] arburst;
rand logic [1:0] arlock;
rand logic [3:0] arcache;
rand logic [2:0] arprot;
//axi read data and response channel - NOT RANDOMIZED (outputs from DUT)
logic [tag_length-1:0] rid;
logic [data_width-1:0] rdata [$];
logic [3:0] rstrb;
logic [1:0] rresp;
logic rlast;
`uvm_object_utils_begin(axi_seq_item)
`uvm_field_enum(status_e, status, UVM_ALL_ON)
`uvm_field_int(awid, UVM_ALL_ON)
`uvm_field_int(awaddr, UVM_ALL_ON)
`uvm_field_int(awlen, UVM_ALL_ON)
`uvm_field_int(awsize, UVM_ALL_ON)
`uvm_field_int(awburst, UVM_ALL_ON)
`uvm_field_int(awlock, UVM_ALL_ON)
`uvm_field_int(awcache, UVM_ALL_ON)
`uvm_field_int(awprot, UVM_ALL_ON)
`uvm_field_int(wid, UVM_ALL_ON)
`uvm_field_queue_int(wdata, UVM_ALL_ON)
`uvm_field_int(wstrb, UVM_ALL_ON)
`uvm_field_int(wlast, UVM_ALL_ON)
`uvm_field_int(bid, UVM_ALL_ON)
`uvm_field_int(bresp, UVM_ALL_ON)
`uvm_field_int(arid, UVM_ALL_ON)
`uvm_field_int(araddr, UVM_ALL_ON)
`uvm_field_int(arlen, UVM_ALL_ON)
`uvm_field_int(arsize, UVM_ALL_ON)
`uvm_field_int(arburst, UVM_ALL_ON)
`uvm_field_int(arlock, UVM_ALL_ON)
`uvm_field_int(arcache, UVM_ALL_ON)
`uvm_field_int(arprot, UVM_ALL_ON)
`uvm_field_int(rid, UVM_ALL_ON)
`uvm_field_queue_int(rdata, UVM_ALL_ON)
`uvm_field_int(rstrb, UVM_ALL_ON)
`uvm_field_int(rresp, UVM_ALL_ON)
`uvm_field_int(rlast, UVM_ALL_ON)
`uvm_object_utils_end
function new(string name = "axi_seq_item");
super.new(name);
endfunction

endclass
