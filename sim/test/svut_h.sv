/// Copyright 2020 The SVUT Authors
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to
/// deal in the Software without restriction, including without limitation the
/// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
/// sell copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
/// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
/// IN THE SOFTWARE.


`ifndef SVUT_DEFINES
`define SVUT_DEFINES

/// Define colors for $display

`define BLUE    "\033[0;34m"
`define GREEN   "\033[0;32m"
`define ORANGE  "\033[1;33m"
`define PINK    "\033[1;35m"
`define RED     "\033[1;31m"
`define NC      "\033[0m"


/// Follows a set of ready to use function to print status
/// and information with an appropriate color.

`define INFO(msg) \
    $display("\033[0;34mINFO: %s (@ %0t)\033[0m", msg, $time)

`define SUCCESS(msg) \
    $display("\033[0;32mSUCCESS: %s (@ %0t)\033[0m", msg, $time)

`define WARNING(msg) \
    $display("\033[1;33mWARNING: %s (@ %0t)\033[0m", msg, $time); \
    svut_warning += 1

`define CRITICAL(msg) \
    $display("\033[1;35mCRITICAL: %s (@ %0t)\033[0m", msg, $time); \
    svut_critical += 1

`define ERROR(msg)\
    $display("\033[1;31mERROR: %s (@ %0t)\033[0m", msg, $time); \
    svut_error += 1

/// SVUT_SETUP is the code portion initializing all the needed
/// variables. To call once before or after the module instance

`define SVUT_SETUP \
    integer svut_status = 0; \
    integer svut_warning = 0; \
    integer svut_critical = 0; \
    integer svut_error = 0; \
    integer svut_error_total = 0; \
    integer svut_nb_test = 0; \
    integer svut_nb_test_success = 0; \
    string svut_test_name = ""; \
    string svut_suite_name = ""; \
    string svut_msg = "";


/// LAST_STATUS is a flag asserted if check the last
/// check function failed
`define LAST_STATUS svut_status

/// Follows a set of macros to check an expression
/// or a signal. All use the same syntax:
///     - a signal or an expression to evaluate
///     - an optional message to print if case the
///       evaluation fails.

/// This function is shared between assertions to format messages
function string create_msg(input string assertion, message);
    if (message != "")
        create_msg = {message, " (", assertion, ")"};
    else
        create_msg = assertion;
endfunction


/// This check will fails if expression is not = 0
`define FAIL_IF(exp, message="") \
    svut_status = 0; \
    svut_msg = create_msg("FAIL_IF", message); \
    if (exp) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end

/// This check will fails if expression is not > 0
`define FAIL_IF_NOT(exp, message="") \
    svut_status = 0; \
    svut_msg = create_msg("FAIL_IF_NOT", message); \
    if (!exp) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end

/// This check will fails if both input are equal
`define FAIL_IF_EQUAL(a,b, message="") \
    svut_status = 0; \
    svut_msg = create_msg("FAIL_IF_EQUAL", message); \
    if (a === b) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end

/// This check will fails if both input are not equal
`define FAIL_IF_NOT_EQUAL(a,b, message="") \
    svut_status = 0; \
    svut_msg = create_msg("FAIL_IF_NOT_EQUAL", message); \
    if (a !== b) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end

/// This check will fails if expression is not = 0
`define ASSERT(exp, message="") \
    svut_status = 0; \
    svut_msg = create_msg("ASSERT", message); \
    if (!exp) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end


/// This header must be placed to start a test suite execution
`define TEST_SUITE(name="") \
    task run(msg=""); \
    begin \
        svut_suite_name = name; \
        svut_msg = {"Start testsuite ", name}; \
        `INFO(svut_msg);

/// This header must be placed to start a test execution
`define UNIT_TEST(name="") \
    begin \
        svut_msg = {"Start test ", name}; \
        `INFO(svut_msg); \
        setup(); \
        svut_test_name = name; \
        svut_error = 0; \
        svut_nb_test = svut_nb_test + 1;

/// This header must be placed to close a test
`define UNIT_TEST_END \
        teardown(); \
        if (svut_error == 0) begin \
            svut_nb_test_success = svut_nb_test_success + 1; \
            `SUCCESS("Test successful"); \
        end else begin \
            `ERROR("Test failed"); \
            svut_error_total += svut_error; \
        end \
    end

/// This header must be placed to close a test suite
`define TEST_SUITE_END \
    end \
    endtask \
    initial begin\
        run(); \
        svut_msg = {"Stop testsuite ", svut_suite_name}; \
        `INFO(svut_msg); \
        if (svut_warning > 0) begin \
            $display("\t\033[1;33m- Warning number: %0d\033[0m", svut_warning); \
        end \
        if (svut_critical > 0) begin \
            $display("\t\033[1;35m- Critical number: %0d\033[0m", svut_critical); \
        end \
        if (svut_error_total > 0) begin \
            $display("\t\033[1;31m- Error number: %0d\033[0m", svut_error_total); \
        end \
        if (svut_nb_test_success != svut_nb_test) begin \
            $display("\t\033[1;31m- STATUS: %0d/%0d test(s) passed\033[0m\n", svut_nb_test_success, svut_nb_test); \
        end else begin \
            $display("\t\033[0;32m- STATUS: %0d/%0d test(s) passed\033[0m\n", svut_nb_test_success, svut_nb_test); \
        end \
        $finish(); \
    end

`endif
