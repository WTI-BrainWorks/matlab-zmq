function varargout = version(varargin)
% zmq.version - Retrieve ZMQ version.
%
% Usage:
%   zmq.version;     % Prints ZMQ version to MATLAB console.
%   v = zmq.version; % Return version string (e.g. '4.0.4').

    [varargout{1:nargout}] = zmq.zmqcore('version', varargin{:});
end
