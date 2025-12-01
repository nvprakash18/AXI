// Declare analysis implementation suffixes for each AXI channel
`uvm_analysis_imp_decl(_aw)
`uvm_analysis_imp_decl(_w)
`uvm_analysis_imp_decl(_b)
`uvm_analysis_imp_decl(_ar)
`uvm_analysis_imp_decl(_r)

class axi_cov extends uvm_subscriber#(axi_seq_item);
    `uvm_component_utils(axi_cov)
    
    // 5 separate analysis exports - one for each AXI channel
    uvm_analysis_imp_aw#(axi_seq_item, axi_cov) aw_ae_port;
    uvm_analysis_imp_w#(axi_seq_item, axi_cov)  w_ae_port;
    uvm_analysis_imp_b#(axi_seq_item, axi_cov)  b_ae_port;
    uvm_analysis_imp_ar#(axi_seq_item, axi_cov) ar_ae_port;
    uvm_analysis_imp_r#(axi_seq_item, axi_cov)  r_ae_port;
    
    // Local variables for sampling
    bit [tag_length-1:0] awid, wid, bid, arid, rid;
    bit [addr_width-1:0] awaddr, araddr;
    bit [3:0] awlen, arlen;
    bit [2:0] awsize, arsize;
    bit [1:0] awburst, arburst, bresp, rresp;
    bit [data_width-1:0] wdata, rdata;
    bit wlast, rlast;
    
    // Coverage for Write Address Channel
    covergroup cg_write_addr;
        cp_awid: coverpoint awid {
            bins id[] = {[0:31]};
        }
        cp_awaddr: coverpoint awaddr {
            bins low_addr  = {[0:63]};
            bins mid_addr  = {[64:191]};
            bins high_addr = {[192:255]};
        }
        cp_awlen: coverpoint awlen {
            bins single   = {0};
            bins burst_2  = {1};
            bins burst_4  = {3};
            bins burst_8  = {7};
            bins burst_16 = {15};
        }
        cp_awsize: coverpoint awsize {
            bins byte     = {0};
            bins halfword = {1};
            bins word     = {2};
        }
        cp_awburst: coverpoint awburst {
            bins fixed = {0};
            bins incr  = {1};
            bins wrap  = {2};
        }
        // Cross coverage
        cross_addr_len: cross cp_awaddr, cp_awlen;
        cross_size_burst: cross cp_awsize, cp_awburst;
    endgroup
    
    // Coverage for Write Data Channel
    covergroup cg_write_data;
        cp_wid: coverpoint wid {
            bins id[] = {[0:31]};
        }
        cp_wdata: coverpoint wdata {
            bins zeros = {0};
            bins ones  = {32'hFFFFFFFF};
            bins others = default;
        }
        cp_wlast: coverpoint wlast {
            bins not_last = {0};
            bins last     = {1};
        }
    endgroup
    
    // Coverage for Write Response Channel
    covergroup cg_write_resp;
        cp_bid: coverpoint bid {
            bins id[] = {[0:31]};
        }
        cp_bresp: coverpoint bresp {
            bins okay   = {2'b00};
            bins exokay = {2'b01};
            bins slverr = {2'b10};
            bins decerr = {2'b11};
        }
    endgroup
    
    // Coverage for Read Address Channel
    covergroup cg_read_addr;
        cp_arid: coverpoint arid {
            bins id[] = {[0:31]};
        }
        cp_araddr: coverpoint araddr {
            bins low_addr  = {[0:63]};
            bins mid_addr  = {[64:191]};
            bins high_addr = {[192:255]};
        }
        cp_arlen: coverpoint arlen {
            bins single   = {0};
            bins burst_2  = {1};
            bins burst_4  = {3};
            bins burst_8  = {7};
            bins burst_16 = {15};
        }
        cp_arsize: coverpoint arsize {
            bins byte     = {0};
            bins halfword = {1};
            bins word     = {2};
        }
        cp_arburst: coverpoint arburst {
            bins fixed = {0};
            bins incr  = {1};
            bins wrap  = {2};
        }
        // Cross coverage
        cross_addr_len: cross cp_araddr, cp_arlen;
        cross_size_burst: cross cp_arsize, cp_arburst;
    endgroup
    
    // Coverage for Read Data Channel
    covergroup cg_read_data;
        cp_rid: coverpoint rid {
            bins id[] = {[0:31]};
        }
        cp_rdata: coverpoint rdata {
            bins zeros = {0};
            bins ones  = {32'hFFFFFFFF};
            bins others = default;
        }
        cp_rresp: coverpoint rresp {
            bins okay   = {2'b00};
            bins exokay = {2'b01};
            bins slverr = {2'b10};
            bins decerr = {2'b11};
        }
        cp_rlast: coverpoint rlast {
            bins not_last = {0};
            bins last     = {1};
        }
    endgroup
    
    function new(string name = "axi_cov", uvm_component parent);
        super.new(name, parent);
        cg_write_addr = new();
        cg_write_data = new();
        cg_write_resp = new();
        cg_read_addr  = new();
        cg_read_data  = new();
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        aw_ae_port = new("aw_ae_port", this);
        w_ae_port  = new("w_ae_port", this);
        b_ae_port  = new("b_ae_port", this);
        ar_ae_port = new("ar_ae_port", this);
        r_ae_port  = new("r_ae_port", this);
    endfunction
    
    // Write function for Write Address Channel
    virtual function void write_aw(axi_seq_item tx);
        awid = tx.awid;
        awaddr = tx.awaddr;
        awlen = tx.awlen;
        awsize = tx.awsize;
        awburst = tx.awburst;
        cg_write_addr.sample();
        `uvm_info("AXI_COV", "Write Address coverage sampled", UVM_HIGH)
    endfunction
    
    // Write function for Write Data Channel
    virtual function void write_w(axi_seq_item tx);
        wid = tx.wid;
        if(tx.wdata.size() > 0) wdata = tx.wdata[0];
        wlast = tx.wlast;
        cg_write_data.sample();
        `uvm_info("AXI_COV", "Write Data coverage sampled", UVM_HIGH)
    endfunction
    
    // Write function for Write Response Channel
    virtual function void write_b(axi_seq_item tx);
        bid = tx.bid;
        bresp = tx.bresp;
        cg_write_resp.sample();
        `uvm_info("AXI_COV", "Write Response coverage sampled", UVM_HIGH)
    endfunction
    
    // Write function for Read Address Channel
    virtual function void write_ar(axi_seq_item tx);
        arid = tx.arid;
        araddr = tx.araddr;
        arlen = tx.arlen;
        arsize = tx.arsize;
        arburst = tx.arburst;
        cg_read_addr.sample();
        `uvm_info("AXI_COV", "Read Address coverage sampled", UVM_HIGH)
    endfunction
    
    // Write function for Read Data Channel
    virtual function void write_r(axi_seq_item tx);
        rid = tx.rid;
        if(tx.rdata.size() > 0) rdata = tx.rdata[0];
        rresp = tx.rresp;
        rlast = tx.rlast;
        cg_read_data.sample();
        `uvm_info("AXI_COV", "Read Data coverage sampled", UVM_HIGH)
    endfunction
    
    // This is required by uvm_subscriber but won't be used (we use individual write_* functions)
    virtual function void write(axi_seq_item t);
        // Not used - we use channel-specific write functions
    endfunction
    
    // Report phase - display coverage results
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("AXI_COV", $sformatf("Write Address Coverage: %.2f%%", cg_write_addr.get_coverage()), UVM_LOW)
        `uvm_info("AXI_COV", $sformatf("Write Data Coverage: %.2f%%", cg_write_data.get_coverage()), UVM_LOW)
        `uvm_info("AXI_COV", $sformatf("Write Response Coverage: %.2f%%", cg_write_resp.get_coverage()), UVM_LOW)
        `uvm_info("AXI_COV", $sformatf("Read Address Coverage: %.2f%%", cg_read_addr.get_coverage()), UVM_LOW)
        `uvm_info("AXI_COV", $sformatf("Read Data Coverage: %.2f%%", cg_read_data.get_coverage()), UVM_LOW)
    endfunction
    
endclass
