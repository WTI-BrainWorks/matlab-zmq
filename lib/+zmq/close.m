function varargout = close(varargin)
% zmq.close- Close a ZMQ socket
%
% Usage: status = zmq.close(socket)
%
% Input: socket - Instantiated ZMQ socket handle to be closed (see zmq.socket).
%
% Output: Zero if successful, otherwise -1.
%

    [varargout{1:nargout}] = zmq.zmqcore('close', varargin{:});
end
