function varargout = ctx_set(varargin)
% zmq.ctx_set - Mex function for setting ZMQ context options. Complementary to zmq.ctx_get.
%
% Usage: zmq.ctx_set(context, option_name, option_value).
%
% Input: context - Instantiated ZMQ context handle (see zmq.ctx_new).
%        option_name - Option string. Must be one of the following:
%                      * ZMQ_IO_THREADS - Number of I/O threads in context thread pool.
%                      * ZMQ_MAX_SOCKETS - Maximum number of sockets allowed on context.
%                      * ZMQ_IPV6 - IPv6 option.
%        option_value - Numerical value to which option_name is to be set. Exception will be
%                       thrown should this fail.
%
% Output: None.

    [varargout{1:nargout}] = zmq.zmqcore('ctx_set', varargin{:});
end
