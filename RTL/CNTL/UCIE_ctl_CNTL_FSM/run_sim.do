vlib work
vlog -f sourcefile.txt   +cover 

vsim -voptargs=+acc work.UCIE_ctl_CNTL_FSM_tb -cover -classdebug -sv_seed 100 -fsmdebug -logfile full_transcript.log

#run 0

do wave.do


#coverage save top.ucdb -onexit -du ALU

run -all
#coverage report -output functional_coverage_rpt.txt -srcfile=* -detail -all -dump -annotate -directive -cvg
#coverage report -output assertion_coverage.txt -detail -assert
 
#for exclusions
#coverage exclude -du ALU -linerange 48-50

#quit -sim

#vcover report top.ucdb -details -annotate -all -output code_coverage_rpt.txt




 