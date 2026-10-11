#include <memory>
#include "verilated.h"
#include "verilated_cov.h"
#include "Vasync_fifo_unit_test.h"

int main(int argc, char** argv) {
    Verilated::debug(0);
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->commandArgs(argc, argv);

    const std::unique_ptr<Vasync_fifo_unit_test> topp{new Vasync_fifo_unit_test{contextp.get()}};

    while (!contextp->gotFinish()) {
        topp->eval();
        if (!topp->eventsPending()) break;
        contextp->time(topp->nextTimeSlot());
    }

    topp->final();
    VerilatedCov::write("coverage.dat");
    return 0;
}