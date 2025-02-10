vlib work
vlog -f ./CNTL/sourcefile.txt -f ./CSR/sourcefile.txt -f ./phy/sourcefile.txt -f ./RX/sourcefile.txt \
 -f ./TX/sourcefile.txt -f ./SB/sourcefile.txt -f ./TB/sourcefile.txt -f ./TOP/sourcefile.txt  +cover 

vsim -voptargs=+acc work.UCIE_ctl_DUT2DUT_tb -cover -classdebug -sv_seed 100 -fsmdebug -logfile full_transcript.log

do wave.do

run -all


#in windows to create sourcefile.txt use dir /b > sourcefile.txt
