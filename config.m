% Please edit this file with the correct paths for ZMQ instalation.
%
% Examples can be found in files `config_unix.m`, `config_win.m`.
% This file itself shows how to build `matlab-zmq` using a Homebrew
% installation of ZMQ 4.0.4 for OS-X.

% ZMQ library filename
if ispc
    ZMQ_COMPILED_LIB = './build/lib/Release/libzmq-v143-mt-s-4_3_5.lib';
    ZMQ_LIB_PATH = './build/lib/Release/';
else
    ZMQ_COMPILED_LIB = './build/lib/libzmq.a';
    ZMQ_LIB_PATH = './build/lib/';
end

% ZMQ library path
%ZMQ_LIB_PATH = '/usr/local/Cellar/zeromq/4.0.4/lib/';

% ZMQ headers path
ZMQ_INCLUDE_PATH = './libzmq/include/';
