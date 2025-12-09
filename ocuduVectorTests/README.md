# OCUDU Vector Tests

The software in this folder provides vector tests for a number of components of the [OCUDU open RAN platform](https://gitlab.com/ocudu/ocudu) in the form of a plugin for the OCUDU software.

## Build Instructions

Clone both the OCUDU and the OCUDU-matlab repositories (if needed).
```bash
$ git clone https://gitlab.com/ocudu/ocudu
$ git clone ???/ocudu_matlab
```

Run MATLAB from the `ocudu_matlab` directory.
```bash
$ cd ocudu_matlab
$ matlab
```

Use MATLAB to generate the test vectors and copy them into the `ocuduVectorTests` folder.
```matlab
>> addpath .
>> runOCUDUunittest('all', 'testvector')
>> ocuduTest.copyOCUDUtestvectors('testvectorOutputs', 'ocuduVectorTests')
```
At this point, the software in the `ocuduVectorTests` folder is ready to be imported as an OCUDU plugin.

Move to the OCUDU working directory and import the plugin as a symbolic link.
```bash
$ cd ../ocudu
$ mkdir -p plugins
$ ln -s ../../ocudu_matlab/ocuduVectorTests plugins/ocudu_vectortests
```

Generate a build system with the `ENABLE_PLUGINS` option activated.
```bash
$ cmake -B buildplugins -DENABLE_PLUGINS:BOOL=ON
```
CMake notifies the inclusion of the vector tests with the message
```bash
-- Adding plugin: plugins/ocudu_vectortests
```

Build the OCUDU software as usual
```bash
$ cmake --build buildplugins -j $(nproc)
```
or, if you are only interested in the vector tests,
```bash
$ cmake --build buildplugins -j $(nproc) --target all_vector_tests
```

The vector tests are added to the OCUDU tests and can be run with
```bash
$ ctest --test-dir buildplugins -j $(nproc) -L vectortest
```
