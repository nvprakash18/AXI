interface axi_intf(logic clk,rst);
//axi wr control channel
logic [tag_length-1:0] awid;
logic [addr_width-1:0] awaddr;
logic [3:0] awlen;
logic [2:0] awsize;
logic [1:0] awburst;
logic [1:0] awlock;
logic [3:0] awcache;
logic [2:0] awprot;
logic awvalid,awready;
//axi wr data channel
logic [tag_length-1:0] wid;
logic [data_width-1:0] wdata;
logic [3:0] wstrb;
logic wlast;
logic wready,wvalid;
//axi wr resp channel
logic bvalid,bready;
logic [tag_length-1:0] bid;
logic [1:0] bresp;
//axi read control cahnnel
logic [tag_length-1:0] arid;
logic [addr_width-1:0] araddr;
logic [3:0] arlen;
logic [2:0] arsize;
logic [1:0] arburst;
logic [1:0] arlock;
logic [3:0] arcache;
logic [2:0] arprot;
logic arvalid,arready;
//axi red data nad responce channel
logic [tag_length-1:0] rid;
logic [data_width-1:0] rdata;
logic [3:0] rstrb;
logic [1:0] rresp;
logic rlast;
logic rready,rvalid;
endinterface
