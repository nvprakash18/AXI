class axi_wr_rd_seq extends uvm_sequence#(axi_seq_item);
    `uvm_object_utils(axi_wr_rd_seq)
    
    // Transaction items
    axi_seq_item wr_tx, rd_tx;
    
    // Shared address and data for write-then-read verification
    rand bit [addr_width-1:0] test_addr;
    rand bit [data_width-1:0] test_data[$];
    rand bit [tag_length-1:0] test_id;
    rand bit [3:0] burst_len;
    
    // Constraints
    constraint c_addr { test_addr inside {[0:255]}; }
    constraint c_burst { burst_len inside {0, 1, 3, 7, 15}; } // Single, 2, 4, 8, 16 beats
    constraint c_data_size { test_data.size() == burst_len + 1; } // awlen+1 data beats
    
    function new(string name = "axi_wr_rd_seq");
        super.new(name);
    endfunction
    
    task body();
        `uvm_info("AXI_SEQ", "Starting Write-Then-Read sequence", UVM_MEDIUM)
        
        // Randomize the shared variables first
        assert(this.randomize());
        
        // ========== WRITE TRANSACTION ==========
        wr_tx = axi_seq_item::type_id::create("wr_tx");
        start_item(wr_tx);
        
        // Configure write transaction
        wr_tx.status = WR;
        
        // Write Address Channel - VALID
        wr_tx.awid = test_id;
        wr_tx.awaddr = test_addr;
        wr_tx.awlen = burst_len;
        wr_tx.awsize = 3'b010; // 4 bytes (32-bit transfer)
        wr_tx.awburst = 2'b01; // INCR burst
        wr_tx.awlock = 2'b00;  // Normal access
        wr_tx.awcache = 4'b0000;
        wr_tx.awprot = 3'b000;
        
        // Write Data Channel - VALID
        wr_tx.wid = test_id;
        wr_tx.wdata = test_data; // Use the randomized test data
        wr_tx.wstrb = 4'b1111;   // All byte lanes valid
        wr_tx.wlast = 1;         // Last transfer
        
        // Write Response Channel - ZERO (will be filled by DUT/Monitor)
        wr_tx.bid = 0;
        wr_tx.bresp = 0;
        
        // Read Channels - ALL ZERO (not used for write)
        wr_tx.arid = 0;
        wr_tx.araddr = 0;
        wr_tx.arlen = 0;
        wr_tx.arsize = 0;
        wr_tx.arburst = 0;
        wr_tx.arlock = 0;
        wr_tx.arcache = 0;
        wr_tx.arprot = 0;
        wr_tx.rid = 0;
        wr_tx.rdata.delete(); // Clear read data queue
        wr_tx.rstrb = 0;
        wr_tx.rresp = 0;
        wr_tx.rlast = 0;
        
        finish_item(wr_tx);
        
        `uvm_info("AXI_SEQ", $sformatf("Write Complete: addr=0x%0h, id=%0d, len=%0d, data[0]=0x%0h", 
                  test_addr, test_id, burst_len, test_data[0]), UVM_MEDIUM)
        
        // Small delay between write and read (optional)
        #10;
        
        // ========== READ TRANSACTION ==========
        rd_tx = axi_seq_item::type_id::create("rd_tx");
        start_item(rd_tx);
        
        // Configure read transaction - SAME address and length as write
        rd_tx.status = RD;
        
        // Read Address Channel - VALID
        rd_tx.arid = test_id;
        rd_tx.araddr = test_addr;      // Same address as write
        rd_tx.arlen = burst_len;       // Same burst length as write
        rd_tx.arsize = 3'b010;         // 4 bytes (32-bit transfer)
        rd_tx.arburst = 2'b01;         // INCR burst
        rd_tx.arlock = 2'b00;          // Normal access
        rd_tx.arcache = 4'b0000;
        rd_tx.arprot = 3'b000;
        
        // Read Data/Response Channel - ZERO (will be filled by DUT/Monitor)
        rd_tx.rid = 0;
        rd_tx.rdata.delete(); // Clear, will be filled by DUT
        rd_tx.rstrb = 0;
        rd_tx.rresp = 0;
        rd_tx.rlast = 0;
        
        // Write Channels - ALL ZERO (not used for read)
        rd_tx.awid = 0;
        rd_tx.awaddr = 0;
        rd_tx.awlen = 0;
        rd_tx.awsize = 0;
        rd_tx.awburst = 0;
        rd_tx.awlock = 0;
        rd_tx.awcache = 0;
        rd_tx.awprot = 0;
        rd_tx.wid = 0;
        rd_tx.wdata.delete(); // Clear write data queue
        rd_tx.wstrb = 0;
        rd_tx.wlast = 0;
        rd_tx.bid = 0;
        rd_tx.bresp = 0;
        
        finish_item(rd_tx);
        
        `uvm_info("AXI_SEQ", $sformatf("Read Complete: addr=0x%0h, id=%0d, len=%0d", 
                  test_addr, test_id, burst_len), UVM_MEDIUM)
        
        // The scoreboard should verify that read data matches the written data
        `uvm_info("AXI_SEQ", "Write-Then-Read sequence completed", UVM_MEDIUM)
    endtask
    
endclass
