FROM registry.fedoraproject.org/fedora-minimal:40
RUN microdnf install -y --setopt=install_weak_deps=False --best  \   
        # SYNTHESIS TOOLS
        yosys trellis nextpnr \
        # ORANGECRAB DFU
        dfu-util \
        #COCOTB INSTALL         
        make python3-pip python3-devel python-pytest \
        gcc g++ libstdc++-devel \
        clang clang15 

# ghdl iverilog verilator