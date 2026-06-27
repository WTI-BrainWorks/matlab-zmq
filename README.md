matlab-zmq
==========

What's this all about?
----------------------

This API aims to bring the awesome of ZMQ to MATLAB. This project has grown out @fagg wanting to
better manage large scale numerical computing experiments across a High Performance Cluster. However,
this library can be used in any number of contexts across any number of machines (even 1 is OK).


Getting Started
---------------

libzmq is bundled as a git submodule and built from source, so you do **not**
need a separate ZMQ install. You do need:

+ CMake and a C/C++ compiler on your `PATH` (used to build the bundled libzmq).
+ A configured `mex` in MATLAB ([what you need](http://www.mathworks.com/help/matlab/matlab_external/what-you-need-to-build-mex-files.html)),
  or Octave with `mkoctfile` (the `liboctave-dev` package on Debian/Ubuntu).

Then:

1. Clone with submodules (libzmq won't be there otherwise):
   ```sh
   git clone --recursive <repo-url>
   # or, in an existing clone:
   git submodule update --init
   ```
2. From MATLAB or Octave, in the repo root, run `make`. This builds the
   bundled libzmq via CMake and compiles a single MEX binary
   (`lib/+zmq/zmqcore.<mexext>`) that statically links it.
3. Put the `lib` directory on your path: `addpath('lib')`.
4. Try it out. The API lives under the `zmq` package:
   ```matlab
   ctx  = zmq.ctx_new();
   sock = zmq.socket(ctx, 'ZMQ_REQ');
   zmq.connect(sock, 'tcp://127.0.0.1:5555');
   zmq.send(sock, uint8('hello'));
   reply = zmq.recv(sock, 100);
   ```
5. Run the test suite with `make test`.

(`config.m` / `config_win.m` / `config_unix.m` are only a fallback for pointing
at a pre-existing ZMQ install when the bundled build can't be used.)

Stuff Doesn't Work
------------------

- Git pull master - make clean; make; make test. Try again.
- Try the dev branch. See if that works.
- If not, open an issue and include the following information:
  - Versions: MATLAB, ZMQ and Operating System
  - Which version of matlab-zmq you're using (i.e. which branch, commit etc).
  - What you are trying to do - preferably include a succinct code example which illustrates the problem.
  - What doesn't work - please describe behaviour explicitly and include any error messages you encounter.

How can I help?
-----------

Pull requests are most welcome. As a general rule, please base all pull requests in master. If in doubt, contact @fagg.

Development Team
-----------------------

- Ashton Fagg (@fagg)
- Anderson Bravalheri (@abravalheri)

Contributors
------------

This project contains contributions from the following people: 

- Ashton Fagg (@fagg)
- Anderson Bravalheri (@abravalheri)
- Matheus Svolenski (@msvolenski)

