test:
	@svutRun -f files.f -define "AFULL=1;AEMPTY=1"
	@svutRun -f files.f -define "AFULL=3;AEMPTY=2"

test-dry-run:
	@svutRun -f files.f -dry-run

gui:
	@svutRun -f files.f -gui

clean:
	@-rm -f *.vcd
	@-rm -f *.lxt*
	@-rm -f *.vvp*
	@-rm -f *.out

