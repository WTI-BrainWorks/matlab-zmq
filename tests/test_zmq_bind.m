function test_zmq_bind
    [ctx, socket] = setup;
    cleanupObj = onCleanup(@() teardown(ctx, socket));

    %% binding
    assert_throw('EPROTONOSUPPORT', @zmq.bind, socket, 'abc://localhost'); % invalid transport - TODO sometimes it throws "zmq:core:bind:unknownOops" ("No such file or directory").
    assert_throw('EINVAL', @zmq.bind, socket, 'tcp://localhost');          % port must specified
    response = assert_does_not_throw(@zmq.bind, socket, 'tcp://127.0.0.1:30000');
    assert(response == 0, 'status code should be 0, %d given.', response);

    %% unbinding
    assert_throw(@zmq.unbind, socket, 'tcp://127.0.0.1:30103');
    response = assert_does_not_throw(@zmq.unbind, socket, 'tcp://127.0.0.1:30000');
    assert(response == 0, 'status code should be 0, %d given.', response);
end

function [ctx, socket] = setup
    % let's just create and destroy a dummy socket
    ctx = zmq.ctx_new();
    socket = zmq.socket(ctx, 'ZMQ_PUB');
end

function teardown(ctx, socket)
    % close session
    zmq.close(socket);
    zmq.ctx_shutdown(ctx);
    zmq.ctx_term(ctx);
end
