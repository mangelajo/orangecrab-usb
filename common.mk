
# `r0.1` or `r0.2` or `r0.2.1`
VERSION ?=r0.2.1
# `25F` or `85F`
DENSITY ?=85F

ifneq (,$(findstring 85,$(DENSITY)))
	NEXTPNR_DENSITY:=--85k
else
	NEXTPNR_DENSITY:=--25k
endif


# Add Windows and Unix support
ECPPLL     = ecppll
RM         = rm -rf
COPY       = cp -a
PATH_SEP   = /
ifeq ($(OS),Windows_NT)
# When SHELL=sh.exe and this actually exists, make will silently
# switch to using that instead of cmd.exe.  Unfortunately, there's
# no way to tell which environment we're running under without either
# (1) printing out an error message, or (2) finding something that
# works everywhere.
# As a result, we force the shell to be cmd.exe, so it works both
# under cygwin and normal Windows.
SHELL      = cmd.exe
COPY       = copy
RM         = del
PATH_SEP   = \\
endif

all: bin/${PROJ}.dfu

dfu: bin/${PROJ}.dfu
	dfu-util --alt 0 -D $<

${PLL_FNAME}.v:
	$(IN_CONTAINER) ecppll -i 48 -o 60 -f ${PLL_FNAME}.v

# We don't actually need to do anything to verilog files.
# This explicitly empty recipe is merely referenced from
# the %.ys recipe below. Since it depends on those files,
# make will check them for modifications to know if it needs to rebuild.
%.v: ;

# Build the yosys script.
# This recipe depends on the actual verilog files (defined in $(VERILOG_FILES))
# Also, this recipe will generate the whole script as an intermediate file.
# The script will call read_verilog for each file listed in $(VERILOG_FILES),
# Then, the script will execute synth_ecp5, looking for the top module named $(TOP_MODULE)
# Lastly, it will write the json output for nextpnr-ecp5 to use as input.
%.ys: $(VERILOG_FILES) Makefile
	$(file >$@)
	$(foreach V,$(VERILOG_FILES),$(file >>$@,read_verilog $V))
	$(file >>$@,synth_ecp5 $(SYNTH_FLAGS) -top $(TOP_MODULE)) \
	$(file >>$@,write_json "$(basename $@).json") \

%.json: %.ys
	cat "$<"
	$(IN_CONTAINER) yosys $(YOSYS_FLAGS) -s "$<"

%_out.config: %.json
	$(IN_CONTAINER) nextpnr-ecp5 --json $< --textcfg $@ $(NEXTPNR_DENSITY) --package CSFBGA285 --lpf synthesis/orangecrab_${VERSION}.pcf

%.bit: %_out.config
	$(IN_CONTAINER) ecppack --compress --freq 38.8 --input $< --bit $@

%.dfu : %.bit
	$(COPY) $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

clean:
	$(RM) -f ${PROJ}.bit ${PROJ}_out.config ${PROJ}.json ${PROJ}.dfu ${PLL_FNAME}.v

.PHONY: prog clean

.SECONDARY: # don't delete intermediate files
