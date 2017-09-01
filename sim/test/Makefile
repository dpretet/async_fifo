UT="*unit_test.sv"

test:
	@svutRun.py -f files.f

gui: test
	@svutRun.py -gui

clean:
	@-rm -f *.vcd
	@-rm -f *.lxt*
	@-rm -f *.vvp*

