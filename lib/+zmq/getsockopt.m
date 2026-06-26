function varargout = getsockopt(varargin)
% zmq.getsockopt - Retrieve ZMQ socket options. Complementary to zmq.setsockopt.
%
% Usage: optvalue = zmq.getsockopt(socket, option_name).
%
% Input: socket - Instantiated ZMQ socket handle (see zmq.socket).
%        option_name - Option string. Please refer to http://api.zeromq.org/master:zmq-getsockopt
%                      for a complete description. Examples:
%                      * ZMQ_TYPE: Retrieve socket type
%                      * ZMQ_BACKLOG: Retrieve maximum length of the queue of outstanding connections
%                      * ZMQ_IPV6: Retrieve IPv6 socket status
%
% Output: Current value for socket option.

    [varargout{1:nargout}] = zmq.zmqcore('getsockopt', varargin{:});
end
