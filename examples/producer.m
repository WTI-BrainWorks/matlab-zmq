function producer
    % A Push socket will distribute sent messages to its Pull clients evenly
    %
    % Example borrowed from
    % http://learning-0mq-with-pyzmq.readthedocs.org/en/latest/pyzmq/patterns/pushpull.html

    context = zmq.ctx_new();
    socket  = zmq.socket(context, 'ZMQ_PUSH');
    address = 'tcp://127.0.0.1:5557';
    zmq.bind(socket, address);

    % NOICE: Start your result manager and workers before you start your producers
    for num = 1:100
        zmq.send(socket, uint8(num2str(num)));
    end

    zmq.disconnect(socket, address);
    zmq.close(socket);

    zmq.ctx_shutdown(context);
    zmq.ctx_term(context);
end
