function varargout = unbind(varargin)
% zmq.unbind - Stop accepting connections on a socket from a endpoint
%
% Usage: status = zmq.unbind(socket, endpoint)
%
% Input: socket   - Instantiated ZMQ socket handle (see zmq.socket).
%        endpoint - String consisting of a 'transport://' followed by an 'address'.
%                   (see zmq.bind).
%
% Output: Zero if successful, otherwise -1.
%

    [varargout{1:nargout}] = zmq.zmqcore('unbind', varargin{:});
end
