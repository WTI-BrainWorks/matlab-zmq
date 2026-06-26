function varargout = disconnect(varargin)
% zmq.disconnect - Disconnect a socket from a endpoint
%
% Usage: status = zmq.disconnect(socket, endpoint)
%
% Input: socket   - Instantiated ZMQ socket handle (see zmq.socket).
%        endpoint - String consisting of a 'transport://' followed by an 'address'.
%                   (see zmq.connect).
%
% Output: Zero if successful, otherwise -1.
%

    [varargout{1:nargout}] = zmq.zmqcore('disconnect', varargin{:});
end
