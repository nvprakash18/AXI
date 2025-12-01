// Declare analysis implementation suffixes for each AXI channel
`uvm_analysis_imp_decl(_aw)
`uvm_analysis_imp_decl(_w)
`uvm_analysis_imp_decl(_b)
`uvm_analysis_imp_decl(_ar)
`uvm_analysis_imp_decl(_r)

class axi_sbd extends uvm_scoreboard;
    `uvm_component_utils(axi_sbd)
    
    // 5 separate analysis exports - one for each AXI channel
    uvm_analysis_imp_aw#(axi_seq_item, axi_sbd) aw_ae_port;
    uvm_analysis_imp_w#(axi_seq_item, axi_sbd)  w_ae_port;
    uvm_analysis_imp_b#(axi_seq_item, axi_sbd)  b_ae_port;
    uvm_analysis_imp_ar#(axi_seq_item, axi_sbd) ar_ae_port;
    uvm_analysis_imp_r#(axi_seq_item, axi_sbd)  r_ae_port;
    
    // Queues to store transactions per channel
    axi_seq_item aw_queue[$];  // Write address queue
    axi_seq_item w_queue[$];   // Write data queue
    axi_seq_item b_queue[$];   // Write response queue
    axi_seq_item ar_queue[$];  // Read address queue
    axi_seq_item r_queue[$];   // Read data queue
    
    // Associative arrays to track outstanding transactions by ID
    axi_seq_item write_addr_pending[int];   // Pending write addresses (key = awid)
    axi_seq_item write_data_pending[int];   // Pending write data (key = wid)
    axi_seq_item read_addr_pending[int];    // Pending read addresses (key = arid)
    
    function new(string name = "axi_sbd", uvm_component parent);
        super.new(name, parent);
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
        axi_seq_item tx_copy;
        $cast(tx_copy, tx.clone());
        aw_queue.push_back(tx_copy);
        write_addr_pending[tx_copy.awid] = tx_copy;
        `uvm_info("AXI_SBD", $sformatf("Write Address: awid=%0d, awaddr=0x%0h, awlen=%0d", 
                  tx_copy.awid, tx_copy.awaddr, tx_copy.awlen), UVM_MEDIUM)
    endfunction
    
    // Write function for Write Data Channel
    virtual function void write_w(axi_seq_item tx);
        axi_seq_item tx_copy;
        $cast(tx_copy, tx.clone());
        w_queue.push_back(tx_copy);
        `uvm_info("AXI_SBD", $sformatf("Write Data: wid=%0d, wdata=0x%0h, wlast=%0b", 
                  tx_copy.wid, tx_copy.wdata[0], tx_copy.wlast), UVM_MEDIUM)
    endfunction
    
    // Write function for Write Response Channel
    virtual function void write_b(axi_seq_item tx);
        axi_seq_item tx_copy, addr_tx;
        $cast(tx_copy, tx.clone());
        b_queue.push_back(tx_copy);
        
        // Match response with pending write address
        if(write_addr_pending.exists(tx_copy.bid)) begin
            addr_tx = write_addr_pending[tx_copy.bid];
            `uvm_info("AXI_SBD", $sformatf("Write Response Matched: bid=%0d, bresp=%0d, addr=0x%0h", 
                      tx_copy.bid, tx_copy.bresp, addr_tx.awaddr), UVM_MEDIUM)
            
            // Check response is OKAY (0x0)
            if(tx_copy.bresp != 2'b00) begin
                `uvm_error("AXI_SBD", $sformatf("Write Response Error: bid=%0d, bresp=%0d", 
                          tx_copy.bid, tx_copy.bresp))
            end
            
            // Remove from pending queue
            write_addr_pending.delete(tx_copy.bid);
        end else begin
            `uvm_warning("AXI_SBD", $sformatf("Write Response without matching address: bid=%0d", 
                        tx_copy.bid))
        end
    endfunction
    
    // Write function for Read Address Channel
    virtual function void write_ar(axi_seq_item tx);
        axi_seq_item tx_copy;
        $cast(tx_copy, tx.clone());
        ar_queue.push_back(tx_copy);
        read_addr_pending[tx_copy.arid] = tx_copy;
        `uvm_info("AXI_SBD", $sformatf("Read Address: arid=%0d, araddr=0x%0h, arlen=%0d", 
                  tx_copy.arid, tx_copy.araddr, tx_copy.arlen), UVM_MEDIUM)
    endfunction
    
    // Write function for Read Data Channel
    virtual function void write_r(axi_seq_item tx);
        axi_seq_item tx_copy, addr_tx;
        $cast(tx_copy, tx.clone());
        r_queue.push_back(tx_copy);
        
        // Match read data with pending read address
        if(read_addr_pending.exists(tx_copy.rid)) begin
            addr_tx = read_addr_pending[tx_copy.rid];
            `uvm_info("AXI_SBD", $sformatf("Read Data Matched: rid=%0d, rdata=0x%0h, rlast=%0b, addr=0x%0h", 
                      tx_copy.rid, tx_copy.rdata[0], tx_copy.rlast, addr_tx.araddr), UVM_MEDIUM)
            
            // Check response is OKAY (0x0)
            if(tx_copy.rresp != 2'b00) begin
                `uvm_error("AXI_SBD", $sformatf("Read Response Error: rid=%0d, rresp=%0d", 
                          tx_copy.rid, tx_copy.rresp))
            end
            
            // If last transfer, remove from pending queue
            if(tx_copy.rlast) begin
                read_addr_pending.delete(tx_copy.rid);
            end
        end else begin
            `uvm_warning("AXI_SBD", $sformatf("Read Data without matching address: rid=%0d", 
                        tx_copy.rid))
        end
    endfunction
    
    // Report phase - check for any outstanding transactions
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info("AXI_SBD", $sformatf("Write Address Count: %0d", aw_queue.size()), UVM_LOW)
        `uvm_info("AXI_SBD", $sformatf("Write Data Count: %0d", w_queue.size()), UVM_LOW)
        `uvm_info("AXI_SBD", $sformatf("Write Response Count: %0d", b_queue.size()), UVM_LOW)
        `uvm_info("AXI_SBD", $sformatf("Read Address Count: %0d", ar_queue.size()), UVM_LOW)
        `uvm_info("AXI_SBD", $sformatf("Read Data Count: %0d", r_queue.size()), UVM_LOW)
        
        if(write_addr_pending.size() > 0) begin
            `uvm_warning("AXI_SBD", $sformatf("Outstanding write addresses: %0d", 
                        write_addr_pending.size()))
        end
        
        if(read_addr_pending.size() > 0) begin
            `uvm_warning("AXI_SBD", $sformatf("Outstanding read addresses: %0d", 
                        read_addr_pending.size()))
        end
    endfunction
    
endclass
