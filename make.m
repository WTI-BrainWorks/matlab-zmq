function success = make(varargin)
  % make.m
  %
  % Tools for building matlab API for ZMQ.
  %
  % ## USAGE:
  %
  % ```matlab
  % >> make % Build the whole core API into a single MEX binary (zmqcore)
  % >> make clean % Remove files produced by compilation process
  % >> make test % Run the test suite
  % ```
  %
  % The whole zmq API is compiled into one MEX binary
  % (`lib/+zmq/zmqcore.<mexext>`) that statically links a single copy of libzmq.
  % The `lib/+zmq/*.m` files are thin shims that forward to it by command name.
  %
  % ## NOTICE:
  %
  % Before runnig this, make sure to install ZMQ and edit 'config.m' file.
  %
  % Instructions for installing ZMQ: http://zeromq.org/intro:get-the-software.
  %
  % The files `config_win.m` and `config_unix.m` are examples of how to edit
  % `config.m` for different operating systems.
  %
  % The file `config.m` itself shows how to build `matlab-zmq` using a Homebrew
  % instalation of ZMQ 4.0.4 for OS-X.

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Rules
  if nargin > 0
    switch lower(varargin{1})
      case 'clean'
        success = clean(varargin{2:end});
      case 'test'
        success = run_tests(varargin{2:end});
      case {'build', 'compile'}
        success = build(varargin{2:end});
      otherwise
        success = build(varargin{:});
    end
  else
    success = build;
  end
end

%% Make rules

function success = clean(varargin)
  % Remove the files generated during compilation process.
  %
  % Arguments:
  %  - [...]: Variable list of paths to be deleted, relative to this file.
  %           No recursive glob patterns can be used.
  %
  % If no argument is provided, all '+zmq/+core/*.mex*', '*.o', '*.asv', '*.m~' files
  % will be remvoed.
  %
  % NOTICE: Without arguments, it will purge the created bindings.
  success = false;

  [make_path, ~, ~, ~] = get_paths();
  if nargin > 0
    rubbish = varargin;
  else
    rubbish = {'lib/+zmq/*.mex*', '*.o', '*.asv', '*.m~'};
  end

  for n = 1:length(rubbish)
    pattern = fullfile(make_path, rubbish{n});
    try
      if ~isempty(dir(pattern))
        delete(pattern); 
      end
    end
  end

  success = true;
end

function success = run_tests(varargin)
  % Run tests for the library
  %
  % ## Arguments
  %   - [...]: variable list of tests.
  %
  % If no argument is provided, all the files `test*.m` under `tests` dir will
  % run.
  %
  % Notice that the files will be considered relative to `tests` directory.
  [make_path, ~, ~, test_path] = get_paths;

  % save current path
  original_path = path;
  addpath(test_path);
  % point at the core package. TODO: this could be tidier
  addpath(fullfile(make_path, 'lib'));
  cleanup = onCleanup(@() path(original_path)); % restore path after finish
  success = runner(varargin{:});
end

function success = build(varargin)
  % Build core ZMQ bindings
  %
  % Compiles the whole zmq API into a single MEX binary
  % (`lib/+zmq/zmqcore.<mexext>`), statically linking one copy of libzmq.
  %
  % ## Arguments
  %   - [...]: optional variable list of source files (paths relative to `src`)
  %            to compile together, overriding the default list. Note that all
  %            handlers, the dispatcher and the util sources must be included for
  %            the binary to link.
  %
  % If no argument is provided, the list is loaded from `compile_list.m`.

  % On Windows/MSVC, interprocedural optimization (/GL + /LTCG) shrinks the
  % final binary by ~8% and links cleanly (the mex link auto-enables LTCG for
  % the /GL static lib). Restrict it to MSVC: on Linux/Octave it is a no-op
  % (Octave already builds mex objects with -flto by default), and the MinGW
  % toolchain Octave uses on Windows would emit LTO objects the mkoctfile link
  % does not consume.
  ipo = '';
  if ispc && ~isoctave
    ipo = ' -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON';
  end
  system(['cmake -S libzmq -B build -DCMAKE_BUILD_TYPE=Release '...
          '-DBUILD_TESTS=OFF -DBUILD_SHARED=OFF -DWITH_LIBBSD=OFF '...
          '-DENABLE_DRAFTS=OFF' ipo]);
  system('cmake --build build --config Release --parallel 4');

  [make_path, lib_path, src_path, ~] = get_paths;

  %% ZMQ CONFIGURATION
  % Prefer the static libzmq just built above. Auto-detecting it (instead of
  % hard-coding a name in config.m) keeps the build working across toolchains
  % whose output differs: MSVC writes build/lib/Release/libzmq-*.lib, while
  % single-config gcc/MinGW write build/lib/libzmq.a.
  libdirs  = {fullfile(make_path, 'build', 'lib', 'Release'), ...
              fullfile(make_path, 'build', 'lib')};
  patterns = {'libzmq*.lib', 'libzmq*.a'};
  ZMQ_COMPILED_LIB = '';
  for di = 1:numel(libdirs)
    for pi = 1:numel(patterns)
      hits = dir(fullfile(libdirs{di}, patterns{pi}));
      if ~isempty(hits)
        ZMQ_COMPILED_LIB = fullfile(libdirs{di}, hits(1).name);
        ZMQ_LIB_PATH     = libdirs{di};
        break;
      end
    end
    if ~isempty(ZMQ_COMPILED_LIB)
      break;
    end
  end

  if ~isempty(ZMQ_COMPILED_LIB)
    ZMQ_INCLUDE_PATH = fullfile(make_path, 'libzmq', 'include');
  else
    % No embedded build found: fall back to a manual/system configuration.
    config;
    if (~testzmq(ZMQ_LIB_PATH) || ~testzmq(ZMQ_INCLUDE_PATH))
      if (ispc)
        config_win;
      else
        config_unix;
      end
      if (~testzmq(ZMQ_LIB_PATH) || ~testzmq(ZMQ_INCLUDE_PATH))
        error('make:matlab-zmq:badConfig', ...
          'Could not find ZMQ files, please edit ''config.m'' and try again.');
      end
    end
  end

  %% SCRIPT VARS

  % --> Windows whitespace normalization :(
  orig_zmq_include_path = ZMQ_INCLUDE_PATH;
  orig_zmq_lib_path = ZMQ_LIB_PATH;
  ZMQ_INCLUDE_PATH = reducepath(ZMQ_INCLUDE_PATH);
  ZMQ_LIB_PATH = reducepath(ZMQ_LIB_PATH);
  % <--

  % --> '-l' option: libname normalization
  orig_zmq_lib = ZMQ_COMPILED_LIB;
  %ZMQ_COMPILED_LIB = regexprep(orig_zmq_lib, '(^lib)|(\.\w+$)', '');
  % <--

  % NOTE: do NOT wrap these paths in quotes. Modern mex (e.g. R2023a) already
  % quotes include/library paths when it assembles the compiler command line;
  % pre-quoting here corrupts that command and mangles MATLAB's own
  % (space-containing) include dirs. Spaces in our paths are handled by
  % reducepath (8.3 short names, above) and by mex's own quoting.
  % -DZMQ_STATIC: we link the embedded libzmq statically. Without this, zmq.h
  % declares the API as __declspec(dllimport) on Windows and the link fails with
  % unresolved __imp_zmq_* symbols. It is harmless on other platforms.
  zmq_compile_flags = { ...
    '-DZMQ_STATIC', ...
    ['-I' src_path], ...
    ['-I' ZMQ_INCLUDE_PATH], ...
    ['-L' ZMQ_LIB_PATH], ...
    ZMQ_COMPILED_LIB ...
  };

  % Static libzmq does not carry its own system dependencies, so the final link
  % (this MEX) must provide them.
  if ispc
    if isoctave
      % Octave ships a MinGW toolchain: link system libs by -l name.
      zmq_compile_flags = [zmq_compile_flags, {'-lws2_32', '-lrpcrt4', '-liphlpapi'}];
    else
      % MSVC: link the Windows import libraries by file name. libzmq needs
      % Winsock (ws2_32), the RPC runtime (rpcrt4, UUIDs) and the IP helper API
      % (iphlpapi).
      zmq_compile_flags = [zmq_compile_flags, {'ws2_32.lib', 'rpcrt4.lib', 'iphlpapi.lib'}];
    end
  elseif ~isoctave
    % MATLAB on Linux/macOS links a C MEX via gcc, so the static C++ libzmq
    % needs the C++ runtime and pthreads named explicitly. (Octave links via
    % g++, which already pulls these in.)
    zmq_compile_flags = [zmq_compile_flags, {'-lstdc++', '-lpthread'}];
  end

  % All sources are compiled together into a single MEX binary. A custom source
  % list (paths relative to `src`) can be passed as arguments, otherwise the
  % default list is loaded from `compile_list.m`.
  if nargin > 0
    SRC_LIST = varargin;
  else
    compile_list;
  end

  % The single binary is a member of the +zmq package (callable as zmq.zmqcore);
  % the thin shims in lib/+zmq/*.m forward to it by command name. It sits
  % directly in the package folder rather than a `private` subfolder because
  % Octave does not resolve private functions inside package folders.
  output_dir = fullfile(lib_path, '+zmq');
  if ~exist(output_dir, 'dir')
    mkdir(output_dir);
  end

  lib_path = reducepath(lib_path); % Windows :(
  outputfile = fullfile(lib_path, '+zmq', 'zmqcore');

  compile(zmq_compile_flags, SRC_LIST, outputfile);

  clean('*.o');

  if exist(fullfile(output_dir, ['zmqcore.' mexext]), 'file')
    success = true;
    fprintf('\nSuccesful build for:\n');
  else
    success = false;
    fprintf('\nErrors during build for:\n');
  end
  fprintf(...
    '\tZMQ_INCLUDE_PATH = %s\n\tZMQ_LIB_PATH = %s\n\tZMQ_COMPILED_LIB = %s\n\n', ...
    orig_zmq_include_path, orig_zmq_lib_path, orig_zmq_lib);
end

%% Aux functions

function compile(flags, src_list, outputfile)
  % Compile all the source files in `src_list` (paths relative to `src`)
  % together into the single MEX binary `outputfile`.
  [~, ~, src_path, ~] = get_paths;

  src_files = cellfun(@(f) fullfile(src_path, f), src_list, ...
                      'UniformOutput', false);

  fprintf('compile %s\n', outputfile);
  cellfun(@(f) fprintf('\t- %s\n', f), src_files);

  if isoctave
    mex(flags{:}, src_files{:}, '-o', dquote(outputfile));
  else
    % TODO: scape properly the `outputfile` to avoid whitespace issues.
    % Inexplicably just using quotes (`sprintf('"%s"', outputfile)` or
    % `['"' outputfile '"']` ) does not work on Windows, even when there are not
    % whitespaces. We rely on reducepath (8.3 short names) instead.
    mex('-largeArrayDims', '-O', ...
        flags{:}, src_files{:}, '-output', outputfile);
  end

  % `strip` removes unneeded symbols and is generally available on POSIX
  % toolchains. It is typically absent on Windows, where the call simply fails
  % and is ignored.
  if ~ispc
    system(sprintf('strip --strip-unneeded %s.%s', outputfile, mexext));
  end
end

function result = isoctave
  % Check if it is octave
  result = exist('OCTAVE_VERSION', 'builtin');
end

function quoted = dquote(file)
  % Double quote strings
  quoted = ['"' file '"'];
end

function red_path = reducepath(orig_path)
  % Unfortunatelly windows has severe issues with spaces in the path
  % strings, even when we scape them with quotes.
  %
  % Thanks to backward compatibility (dating back to MS-DOS times), it's
  % possible to convert the paths to an alternate ancient short form
  % (http://en.wikipedia.org/wiki/8.3_filename).
  %
  % The black magic necessary to do so was found in:
  % - http://stackoverflow.com/questions/1333589/how-do-i-transform-the-working-directory-into-a-8-3-short-file-name-using-batch
  % - http://stackoverflow.com/questions/10227144/convert-long-filename-to-short-filename-8-3-using-cmd-exe
  %
  % There is an alternate procedure, as documented in:
  % http://www.mathworks.com/matlabcentral/answers/93932-how-can-i-get-the-short-path-for-a-windows-long-path-using-matlab-7-8-r2009a
  %
  % TODO: consider the much nicer second alternative. Is it reliable in a
  % wide range of environments (diferent versions of Windows, even the
  % future ones)?

  if ispc
    [status, red_path] = system(['for %A in ("', orig_path ,'") do @echo %~sA']);
    if status; error('system:reducepath', 'Unable to recognize path'); end
    red_path = strtrim(red_path);
  else
    red_path = orig_path;
  end
end

function response = testzmq(folder)
  % Test if there are any zmq files inside folder

  try
    files = dir(fullfile(folder, '*zmq*'));
  catch
    files = [];
  end

  if ~isempty(files)
    response = 1;
  else
    response = 0;
  end
end

function [make_path, lib_path, src_path, test_path] = get_paths()
  % Return the paths used for this library

  [make_path, ~, ~] = fileparts(mfilename('fullpath'));
  lib_path = fullfile(make_path, 'lib/');
  src_path = fullfile(make_path, 'src');
  test_path = fullfile(make_path, 'tests');
end





