function varargout = ctx_new(varargin)
% zmq.ctx_new - Create new context for use with ZMQ functions
%
% Usage: context = zmq.ctx_new
%
% Input: None
%
% Output: Handle to the instantiated ZMQ context

    [varargout{1:nargout}] = zmq.zmqcore('ctx_new', varargin{:});
end
