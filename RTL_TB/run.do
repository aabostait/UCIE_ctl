vlib work
vlog -f sourcefile.txt +cover 
vsim -voptargs=+acc work.UCIE_ctl_phy_dut_to_dut_top_tb -cover
add wave *
add wave -position insertpoint sim:/UCIE_ctl_phy_dut_to_dut_top_tb/dut_to_dut/phy_top_DUT1/Control_DUT/*
add wave -position insertpoint sim:/UCIE_ctl_phy_dut_to_dut_top_tb/dut_to_dut/phy_top_DUT2/Control_DUT/*
add wave -position insertpoint sim:/UCIE_ctl_phy_dut_to_dut_top_tb/dut_to_dut/phy_top_DUT1/Data_transfer_DUT/*
add wave -position insertpoint sim:/UCIE_ctl_phy_dut_to_dut_top_tb/dut_to_dut/phy_top_DUT2/Data_transfer_DUT/*
add wave -position insertpoint sim:/UCIE_ctl_phy_dut_to_dut_top_tb/dut_to_dut/phy_top_DUT1/SB_interface_DUT/*
add wave -position insertpoint sim:/UCIE_ctl_phy_dut_to_dut_top_tb/dut_to_dut/phy_top_DUT2/SB_interface_DUT/*


run -all



