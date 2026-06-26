function varargout = setsockopt(varargin)
% zmq.setsockopt - Set ZMQ socket options. Complementary to zmq.getsockopt.
%
% Usage: status = zmq.getsockopt(socket, optionName, optionValue).
%
% Input: socket - Instantiated ZMQ socket handle (see zmq.socket).
%        optionName  - Option string. Please refer to http://api.zeromq.org/master:zmq-setsockopt
%                      for a complete description. Examples:
%                      * ZMQ_TYPE: Retrieve socket type
%                      * ZMQ_BACKLOG: Retrieve maximum length of the queue of outstanding connections
%                      * ZMQ_IPV6: Retrieve IPv6 socket status
%        optionValue - New value for option. Please refer to http://api.zeromq.org/master:zmq-setsockopt
%                      for a complete description.
%
% Output:  Zero if successful, otherwise -1 .

    [varargout{1:nargout}] = zmq.zmqcore('setsockopt', varargin{:});
end
