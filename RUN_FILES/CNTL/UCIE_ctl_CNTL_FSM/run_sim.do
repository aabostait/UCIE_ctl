vlib work
vlog -f CNTL/UCIE_ctl_CNTL_FSM/sourcefile.txt +cover \
+incdir+../RTL_TB/CNTL/UCIE_ctl_CNTL_FSM/ \
+incdir+../RTL/CNTL/UCIE_ctl_CNTL_FSM/

vsim -voptargs=+acc work.UCIE_ctl_CNTL_FSM_tb -cover -classdebug -sv_seed 100 -fsmdebug -logfile full_transcript.log

do wave.do

run -all
