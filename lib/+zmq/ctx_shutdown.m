function varargout = ctx_shutdown(varargin)
% zmq.ctx_shutdown - Shutdown a ZMQ context.
%
% Usage: zmq.ctx_shutdown(context)
%
% Input: context - Instantiated ZMQ context handle (see zmq.ctx_new).
%
% Output: None.

    [varargout{1:nargout}] = zmq.zmqcore('ctx_shutdown', varargin{:});
end
