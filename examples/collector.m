function collector
    % A collector receive the results sent from workers and aggregate them.
    %
    % Example borrowed from
    % http://learning-0mq-with-pyzmq.readthedocs.org/en/latest/pyzmq/patterns/pushpull.html

    context = zmq.ctx_new();
    socket  = zmq.socket(context, 'ZMQ_PULL');
    address = 'tcp://127.0.0.1:5558';
    zmq.bind(socket, address);

    total = 0;
    for x = 1:50
        result = sscanf(char(zmq.recv(socket)), '%d %d');
        fprintf('data received from consumer#%d: %d\n', result(1), result(2));
        total = total + result(2);
    end

    fprintf('\nTotal: %d\n', total);

    zmq.disconnect(socket, address);
    zmq.close(socket);

    zmq.ctx_shutdown(context);
    zmq.ctx_term(context);
end
