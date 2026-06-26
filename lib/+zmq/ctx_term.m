function varargout = ctx_term(varargin)
% zmq.ctx_term - Destroy ZMQ context.
%
% Usage: zmq.ctx_term(context)
%
% Input: context - Instantiated ZMQ context (see zmq.context_new).
%
% Output: None.


    [varargout{1:nargout}] = zmq.zmqcore('ctx_term', varargin{:});
end
