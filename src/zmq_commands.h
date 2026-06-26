#ifndef _ZMQ_COMMANDS_H_
#define _ZMQ_COMMANDS_H_

#include <mex.h>

/*
  Each of these is a former `mexFunction` entry point, now a named command
  handler. They are dispatched from the single `mexFunction` in zmq_dispatch.c,
  which strips the leading command-name argument before calling them. As a
  result, each handler sees exactly the same (nlhs, plhs, nrhs, prhs) layout it
  did when it was an independent MEX file.
 */
void cmd_version(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_ctx_new(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_ctx_term(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_ctx_shutdown(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_ctx_get(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_ctx_set(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_socket(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_close(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_bind(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_unbind(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_connect(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_disconnect(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_getsockopt(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_setsockopt(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_send(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);
void cmd_recv(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]);

#endif
