/// Copyright 2021 The SVUT Authors
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

/// 1 set bold
/// 2 set half-bright (simulated with color on a color display)
/// 4 set underscore (simulated with color on a color display)
/// 5 set blink
/// 7 set reverse video

`define BLACK   "\033[1;30m"
`define RED     "\033[1;31m"
`define GREEN   "\033[1;32m"
`define BROWN   "\033[1;33m"
`define BLUE    "\033[1;34m"
`define PINK    "\033[1;35m"
`define CYAN    "\033[1;36m"
`define WHITE   "\033[1;37m"

`define BG_BLACK   "\033[1;40m"
`define BG_RED     "\033[1;41m"
`define BG_GREEN   "\033[1;42m"
`define BG_BROWN   "\033[1;43m"
`define BG_BLUE    "\033[1;44m"
`define BG_PINK    "\033[1;45m"
`define BG_CYAN    "\033[1;46m"
`define BG_WHITE   "\033[1;47m"

`define NC "\033[0m"

/// Follows a set of ready to use function to print status
/// and information with an appropriate color.

`define MSG(msg) \
    $display("\033[0;37m%s (@ %0t)\033[0m", msg, $realtime)

`define INFO(msg) \
    $display("\033[0;34mINFO: %s (@ %0t)\033[0m", msg, $realtime)

`define SUCCESS(msg) \
    $display("\033[0;32mSUCCESS: %s (@ %0t)\033[0m", msg, $realtime)

`define WARNING(msg) \
    begin\
    $display("\033[1;33mWARNING: %s (@ %0t)\033[0m", msg, $realtime);\
    svut_warning += 1;\
    end

`define CRITICAL(msg) \
    begin\
    $display("\033[1;35mCRITICAL: %s (@ %0t)\033[0m", msg, $realtime);\
    svut_critical += 1;\
    end

`define ERROR(msg)\
    begin\
    $display("\033[1;31mERROR: %s (@ %0t)\033[0m", msg, $realtime);\
    svut_error += 1;\
    end

/// SVUT_SETUP is the code portion initializing all the needed
/// variables. To call once before or after the module instance
`define SVUT_SETUP \
    integer svut_test_number = 0; \
    string testnum; \
    integer svut_status = 0; \
    integer svut_warning = 0; \
    integer svut_critical = 0; \
    integer svut_error = 0; \
    integer svut_error_total = 0; \
    integer svut_nb_test = 0; \
    integer svut_nb_test_success = 0; \
    string svut_test_name = ""; \
    string svut_suite_name = ""; \
    string svut_msg = ""; \
    string svut_fail_list = "Failling test(s):";

/// LAST_STATUS is a flag asserted if check the last
/// check function failed
`define LAST_STATUS svut_status

/// This function is shared between assertions to format messages
function automatic string create_msg(input string assertion, message);
    if (message != "") begin
        create_msg = {message, " (", assertion, ")"};
    end else begin
        create_msg = assertion;
    end
endfunction

/// Follows a set of macros to check an expression
/// or a signal. All use the same syntax:
///     - a signal or an expression to evaluate
///     - an optional message to print if case the
///       evaluation fails.

/// This check fails if expression is not = 0
`define FAIL_IF(exp, message="") \
    svut_status = 0; \
    svut_msg = create_msg("FAIL_IF", message); \
    if (exp) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end

/// This check fails if expression is not > 0
`define FAIL_IF_NOT(exp, message="") \
    svut_status = 0; \
    svut_msg = create_msg("FAIL_IF_NOT", message); \
    if (!exp) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end

/// This check fails if both input are equal
`define FAIL_IF_EQUAL(a,b, message="") \
    svut_status = 0; \
    svut_msg = create_msg("FAIL_IF_EQUAL", message); \
    if (a === b) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end

/// This check fails if both input are not equal
`define FAIL_IF_NOT_EQUAL(a,b, message="") \
    svut_status = 0; \
    svut_msg = create_msg("FAIL_IF_NOT_EQUAL", message); \
    if (a !== b) begin \
        `ERROR(svut_msg); \
        svut_status = 1; \
    end

/// This check fails if expression is not = 0
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
        $display("");\
        svut_msg = {"Start testsuite << ", name, " >>"}; \
        `INFO(svut_msg);

/// This header must be placed to start a test execution
`define UNIT_TEST(name="") \
    begin \
        $display("");\
        $sformat(testnum, "%0d", svut_test_number); \
        svut_msg = {"Starting << ", "Test ", testnum, ": ", name, " >>"}; \
        `INFO(svut_msg); \
        setup(); \
        svut_test_name = name; \
        svut_error = 0; \
        svut_nb_test = svut_nb_test + 1;

/// This footer must be placed to close a test
`define UNIT_TEST_END \
        teardown(); \
        if (svut_error == 0) begin \
            svut_nb_test_success = svut_nb_test_success + 1; \
            svut_msg = {"Test ", testnum, " pass"}; \
            `SUCCESS(svut_msg); \
        end else begin \
            svut_msg = {"Test ", testnum, " fail"}; \
            `ERROR(svut_msg); \
            svut_fail_list = {svut_fail_list, " '", svut_test_name, "'"}; \
            svut_error_total += svut_error; \
        end \
        svut_test_number = svut_test_number + 1; \
    end

/// This footer must be placed to close a test suite
`define TEST_SUITE_END \
    end \
    endtask \
    initial begin\
        run(); \
        $display("");\
        svut_msg = {"Stop testsuite '", svut_suite_name, "'"}; \
        `INFO(svut_msg); \
        if (svut_error_total > 0) begin \
            $display("\033[1;31m"); \
            $display(svut_fail_list); \
            $display(""); \
        end \
        $display("  \033[1;33m- Warning number:  %0d\033[0m", svut_warning); \
        $display("  \033[1;35m- Critical number: %0d\033[0m", svut_critical); \
        $display("  \033[1;31m- Error number:    %0d\033[0m", svut_error_total); \
        if (svut_nb_test_success != svut_nb_test) begin \
            $display("  \033[1;31m- STATUS: %0d/%0d test(s) passed\033[0m\n", svut_nb_test_success, svut_nb_test); \
        end else begin \
            $display("  \033[0;32m- STATUS: %0d/%0d test(s) passed\033[0m\n", svut_nb_test_success, svut_nb_test); \
        end \
        $finish(); \
    end

`endif
