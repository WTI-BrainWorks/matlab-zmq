/* zmq_dispatch.c - Single MEX entry point for the whole zmq.* API.
 *
 * Every command that used to be its own MEX file (send, recv, bind, ...) is now
 * a `cmd_*` handler compiled into this one binary, which statically links libzmq
 * a single time. The MATLAB shims in lib/+zmq/*.m call this binary as:
 *
 *     zmq.zmqcore('<command>', arg1, arg2, ...)
 *
 * We strip prhs[0] (the command name) and forward (nlhs, plhs, nrhs-1, prhs+1)
 * to the matching handler, so each handler sees the exact argument layout it saw
 * back when it was an independent MEX function.
 */
#include <mex.h>
#include <string.h>
#include <stdio.h>
#include <zmq_commands.h>

typedef void (*cmd_fn)(int, mxArray *[], int, const mxArray *[]);

typedef struct {
    const char *name;
    cmd_fn fn;
} command_t;

static const command_t commands[] = {
    {"version",      cmd_version},
    {"ctx_new",      cmd_ctx_new},
    {"ctx_term",     cmd_ctx_term},
    {"ctx_shutdown", cmd_ctx_shutdown},
    {"ctx_get",      cmd_ctx_get},
    {"ctx_set",      cmd_ctx_set},
    {"socket",       cmd_socket},
    {"close",        cmd_close},
    {"bind",         cmd_bind},
    {"unbind",       cmd_unbind},
    {"connect",      cmd_connect},
    {"disconnect",   cmd_disconnect},
    {"getsockopt",   cmd_getsockopt},
    {"setsockopt",   cmd_setsockopt},
    {"send",         cmd_send},
    {"recv",         cmd_recv},
    {NULL,           NULL}
};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    char *cmd = NULL;
    int i;

    if (nrhs < 1 || mxIsChar(prhs[0]) != 1 || mxGetM(prhs[0]) != 1) {
        mexErrMsgIdAndTxt("zmq:core:dispatch:invalidCommand",
                "Error: first argument must be a command name (row string).");
        return;
    }

    cmd = mxArrayToString(prhs[0]);
    if (cmd == NULL) {
        mexErrMsgIdAndTxt("zmq:core:dispatch:invalidCommand",
                "Error: could not read command name.");
        return;
    }

    for (i = 0; commands[i].name != NULL; i++) {
        if (strcmp(cmd, commands[i].name) == 0) {
            mxFree(cmd);
            commands[i].fn(nlhs, plhs, nrhs - 1, prhs + 1);
            return;
        }
    }

    {
        char errmsg[128];
        snprintf(errmsg, sizeof(errmsg), "Error: unknown command '%s'.", cmd);
        mxFree(cmd);
        mexErrMsgIdAndTxt("zmq:core:dispatch:unknownCommand", "%s", errmsg);
    }
}
