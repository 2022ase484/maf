# Result Invalidation for Incremental Modular Analyses

This artifact consists of the source code of our incremental analysis and of its
evaluation, together with the two benchmarking suites that were used as part of
the evaluation. In addition, CSV files containing our measurements and scripts
to generate the graphs have been included as well.

The artifact contains all the code of the framework in which we have implemented and evaluated our incremental analysis.
Relative to the root folder of the artifact (located on ~/Desktop/maf):
* the source code can be found in `code`
* the curated benchmarking suite can be found in `test/changes/scheme` and `test/changes/scheme/reinforcingcycles`;
* the generated benchmarking suite can be found in `test/changes/scheme/generated`;
* the CSV files containing our raw measurements are located in `benchOutput/ase-data`;
* scripts to generate the graphs of the paper are located in `benchOutput`.

Specifically:
* the code concerning the incremental analysis and the invalidation strategies can be found in `code/shared/main/scala/maf/modular/incremental`;
* the code for the performance and precision evaluation can be found in `code/jvm/src/main/scala/maf/cli/experiments/incremental`;
* the code for the soundness evaluation can be found in `code/shared/src/test/scala/maf/text/modular/scheme/incremental`.

We claim the following badges for our artifact: available and reusable.

## Claims about the artifact’s functionality, reusability and extensibility

Our artifact supports the following data and conclusions from the paper:
* The soundness evaluation described in §5 corresponds to executing the unit tests of the incremental analysis.
* Figures 5 and 6 (RQ1, §6) can be obtained by
  1. running the precision evaluation on both the curated and the generated data set, and
  2. executing the Python script `benchOutput/precision.py` to obtain the figures.
* Figures 7 and 8 (RQ2 and RQ3, §6) can be obtained by
  1. running the performance evaluation on both the curated and the generated data set, and
  2. executing the Python script `benchOutput/performance.py` to obtain the figures.

We now list the commands needed to execute the functionality described above,  lines starting with `//` are comments (note that these commands run the _entire_ evaluation).
```
// Navigate to the source code directory. Open an sbt repl.
sbt

// Run the soundness evaluation (§5).
maf/testOnly -- -n IncrementalTest

// Run the precision and performance evaluation (§6).
maf/runMain maf.cli.experiments.incremental.RunIncrementalEvaluation --performance --precision --curated --generated --type --cp

// Exit the sbt repl.
exit

// Create the precision and performance graphs (§6).
cd benchOutput
for file in *.csv; do grep -v ", ," $file | grep -v "∞" | sponge $file; done
python3 precision.py
python3 performance.py
```

For more precise instructions on how to execute (part of) the evaluation, and on the scripts to generate the graphs, we refer to the section _Getting Started_ of this readme.
Note that the paper only includes the data of the analyses when run with the type lattice, whereas graphs for the constant-propagation lattice may also be produced.

In `benchOutput/ase-data`, we have listed the data files obtained from running the soundness and performance evaluations, that we used to create the graphs.
Of course, as this artifact will be run on hardware that differs from ours and within a VM, the exact numbers obtained for the performance evaluation may differ from ours.
(We ran our evaluation on a 2015 Dell PowerEdge R730 with 2 Intel Xeon 2637 processors and 256GB of RAM, with OpenJDK 1.8.0_312 and Scala 3.1.0. The JVM was given a maximum of 32GB RAM.)

The activities in the paper that have lead to the creation of this artifact are the implementation and evaluation of the incremental analysis and the result invalidation strategies that have been proposed in the paper.

### Extending the Artifact's Functionality

We have implemented our analyses in a framework for facilitating the implementation of effect-driven modular analyses.
(This artifact comprises most of the source code of the framework, as well as our own additions.)
For example, using the framework, experiments with (new) context-sensitivities, lattices, semantics, work list orders,... can be performed using this framework.
By implementing our analysis and strategies within this framework, we allow our incremental analysis and the implemented strategies to be reused.
In addition, our strategies can be used for experiments in different settings.
Furthermore, our implementation can be extended and modified: the structure of the framework allows to change one part of the implementation to be updated whilst the other parts can be reused.
Besides changes to the core analysis, client analyses can be implemented as well, so that it can e.g., be investigated how the strategies presented in the paper influence the precision of these client analyses.
Hence, this artifact can be used to perform additional experiments and to build (incremental) analyses that rely (partially) on our implementation.

Possible modifications to the analysis/strategies can be, but are not limited to:
* implementing new invalidation strategies,
* changing the front-end, so that the incremental analysis can be applied to different languages,
* adding more strategies,
* combining our incremental work with other work on modular analyses or specific optimisations (e.g., adaptive analyses),
* ...

The future work listed in the paper will build on/extend the functionalities in this artifact.

#### Example
To construct an analysis in the framework, several traits need to be mixed into the ModAnalysis class.
For example, some instances of incremental modular analyses have been defined in the file `code/shared/src/main/scala/maf/modular/incremental/scheme/IncrementalSchemeAnalysisInstantiations.scala`.

To add/modify functionality, the new functionality can be implemented in a Scala trait which overrides the behaviour of e.g., the language semantics or even of the modular analysis itself. 
By mixing in this trait, an analysis containing this new behaviour is obtained.
In addition, when the behaviour of the intra-component analysis is altered, the method `intraAnalysis` needs to be overridden, so that it creates intra-component analyses that exhibit the modified behaviour.
In essence, the incremental analysis implemented in this framework is a modular analysis which has been extended by adding incremental capabilities.

Several possible functionality extensions are already provided in the artifact source code.
For example, we have implemented an analysis logger, and an assertion evaluation, which, during the analysis, checks which assertions expressed in the source code hold and which do not:
* By default, the analysis ignores assertions in the source code.
However, when an analysis mixes in the trait `SchemeAssertSemantics` (`code/shared/src/main/scala/maf/modular/scheme/modf/SchemeAssertSemantics.scala`), the behaviour of the analysis is extended and assertions are verified by the analysis when it is run.
A predefined analysis class that mixes in this trait is `IncrementalSchemeModFAssertionAnalysisTypeLattice`, which can be found in `code/shared/src/main/scala/maf/modular/incremental/scheme/IncrementalSchemeAnalysisInstantiations.scala`.
* It is difficult to debug an analysis, for which the artifact contains a trait 
`IncrementalLogging` (defined in the file `code/shared/src/main/scala/maf/modular/incremental/IncrementalLogging.scala`).
Whenever an analysis that has mixed-in this trait is run, a new log file will be created and stored in the folder `logs`.
In addition, the granularity of logging can be changed, by overriding/changing the `mode` attribute.
As an example of how incremental logging can be used, one could for example construct an incremental analysis with logging as follows:
```Scala
def newAnalysis(text: SchemeExp, configuration: IncrementalConfiguration) =
  new IncrementalSchemeModFAnalysisTypeLattice(text, configuration)
  with IncrementalLogging[SchemeExp]
  {
    // Only produce a summary of the analysis (coarse-grained logging).
    mode = Mode.Summary 

    // Make sure the intra-component analyses use the added behaviour.
    override def intraAnalysis(cmp: SchemeModFComponent) = new IntraAnalysis(cmp) with IncrementalSchemeModFBigStepIntra 
    with IncrementalGlobalStoreIntraAnalysis 
    with IncrementalLoggingIntra
  }
```

An analysis with logging can easily be run as follows:
1. In `code/jvm/src/main/scala/maf/cli/runnables/IncrementalRun.scala`, replace the definition of `newAnalysis` by the definition given above. (This file is mostly used for debugging purposes, and already contains some other definitions of analyses that employ logging.)
2. Run the `IncrementalRun` object. To do so, navigate to `~/Desktop/maf` and open an sbt repl by typing the `sbt` command, and execute the following command: `maf/runMain maf.cli.runnables.IncrementalRun`. This will print some output to the terminal.
3. When the analysis has terminated, consult the logs in the `logs` directory.

## Claims about the artifact’s functionality

We agree to publish our artifact online.
We have implemented the presented work in an open-source repository which is available on GitHub.
The repository is dual-licensed, and our work will be licensed accordingly.
The project is free to use for non-commercial purposes under the conditions of the GPL 3.0 license.

## Artifact Requirements

To run the artifact, some software such as Sbt and Python3, and some command line tools, may need to be installed.

The artifact does not require specific hardware for it to be run on.
Nonetheless, depending on the hardware, the exact results for the performance evaluation may differ from ours.
We have performed our evaluation with 32GB of RAM.

## Getting Started

We now describe how to execute the various parts of the artifact: performing the soundness evaluation, performing the precision and performance evaluation, and creating the graphs.
Within the virtual machine, all commands can be run using the command line.

For all steps, except the graph creation, the commands must be run in a sbt shell.
To start such a shell, open a terminal and navigate to the artifact folder `maf`. Then execute the `sbt` command in the terminal.
To change the memory available to the JVM, e.g., to use a maximum of 32GB as we did for our experiments, run the command `sbt -J-Xmx32G` instead (note that this may require giving more memory to the virtual machine that runs the artifact).
The first time a command is executed, sbt will automatically compile all source code, this does not have to be done manually.

We now briefly list a few commands that can be used to verify whether all functionality in the artifact can be executed.
When the virtual machine is started:

* To briefly run the performance and precision evaluation on a part of the data set, navigate to the artifact folder `maf` and execute the `sbt` command to open the sbt shell.
  Then, execute following command:
  ```
  maf/runMain maf.cli.experiments.incremental.RunIncrementalEvaluation --performance --precision --curated --generated --type --cp --repet 5 --count 2
  ```
  On a 2019 MacBook Pro with an 2,3 GHz 8-Core Intel Core i9 and 4GB of RAM made available to the JVM, this command completed in just over 8 minutes.
  When this command has been run, output files (in CSV format) should be present in the `benchOutput` folder.
* To verify whether the graphs can be correctly produced, run the following commands (outside of the sbt shell, which can be quit using the `exit` command):
  ```
  cd benchOutput
  for file in *.csv; do grep -v ", ," $file | grep -v "∞" | sponge $file; done
  python3 precision.py
  python3 performance.py
  ```
  This generates PDF files containing the graphs.
  These commands should not take more than a couple of minutes to be run.
  Note that the bottom performance graphs may be empty since only a part of the dataset is used.

These commands cover both Scala and Python functionality.
When they work correctly, the artifact should run correctly.
However, depending on the resources given to the virtual machine, analyses may timeout.

More information on how the evaluation can be run, can be found in the sections below.

### Soundness Evaluation
To run the soundness tests the command `maf/testOnly -- -n IncrementalTest` can be evaluated.
The entire test suite may take several hours to run, a subset of the tests can be run using `maf/testOnly -- -n IncrementalTest -l SlowTest`.
Note that even this subset of test may still take a long time to run.
To further reduce the running time of the tests, one can remove benchmark programs from the following directories:
* `test/changes/cscheme/threads`,
* `test/changes/scheme`,
* `test/changes/scheme/generated`,
* `text/changes/scheme/reinforcingcycles`,

so that the tests are run on less programs. As some programs are referenced explicitly from the tests, please do not remove
* `test/changes/scheme/fib.scm`,
* `test/changes/scheme/satRem.scm`,
* `test/changes/scheme/ring-rotate.scm`,
* `test/changes/cscheme/threads/actors.scm`,
* `test/changes/cscheme/threads/mcarlo.scm`

since otherwise, the corresponding tests will fail.

### Precision and Performance Evaluation
To run the precision and performance evaluation, the command `maf/runMain maf.cli.experiments.incremental.RunIncrementalEvaluation` needs to be run.
However, it is needed to provide arguments, to indicate which parts of the evaluation need to be run.
The possible arguments for this command are:
* `--performance`: indicates that the performance experiments need to be run,
* `--precision`: indicates that the precision experiments need to be run,
* `--curated`: indicates that the curated benchmarking suite needs to be used,
* `--generated`: indicates that the generated benchmarking suite needs to be used,
* `--type`: indicates that the experiments need to be run with the type lattice,
* `--cp`: indicates that the experiments need to be run with the constant-propagation lattice
* `--warmup n`: indicates that there are (maximally) `n` warmup runs used by the performance evaluation (default: 3),
* `--repet n`: indicates that there need to be `n` measured runs for each performance experiment (default: 15),
* `--count n`: indicates that only `n` benchmarks from the selected benchmarking suites need to be used (default: use all).

Any combination of arguments can be used.
For example, if both the `--type` and `--cp` arguments are provided, then all experiments will be executed twice, once using the type lattice and once using the constant-propagation lattice.
However, to run experiments, at least one type of experiment (performance/precision), one benchmark suite (curated/generated), and one lattice (type/cp) need to be provided.
For example, to run the precision evaluation on the curated benchmarking suite with the type lattice, the following command can be executed:
```
maf/runMain maf.cli.experiments.incremental.RunIncrementalEvaluation --precision --curated --type
```

Using our setup, the entire evaluation took +- 5 days for each lattice running all experiments.
The `--warmup`, `--repet`, and `--count` arguments can be used to reduce this.
For example, to run all experiments using only 2 benchmarks per benchmarking suite, with only 5 repetitions per experiment, the following command can be executed:
```
maf/runMain maf.cli.experiments.incremental.RunIncrementalEvaluation --performance --precision --curated --generated --type --cp --repet 5 --count 2
```
On a 2019 MacBook Pro with an 2,3 GHz 8-Core Intel Core i9 and 4GB of RAM made available to the JVM, this command completed in just over 8 minutes.

Note that during the execution of the commands, progress indicators may be printed to the command line.
Also note that by default, all possible configurations of the incremental analysis are used in the experiments.
The configurations used are not configurable from the command line.
If however one wants to use specific configurations, the easiest way to do so is to remove unwanted configurations from the list
`allConfigurations` defined in file `src/main/scala/maf/modular/incremental/IncrementalConfiguration.scala`.

### Graph Generation
Reminder: for the generation of the graphs, the commands must not be run in a sbt shell.
To execute the commands, navigate to `benchOutput` in the project folder.

Once the precision and/or performance evaluation have been run, graphs can be created.
Before being able to generate the graphs, a small preprocessing step is needed to remove data from benchmarks that have timeout, since this data is not usable.
To this end, execute the following command:
```
for file in *.csv; do grep -v ", ," $file | grep -v "∞" | sponge $file; done
```

Once the data is cleaned, the actual graphs can be created.
For this, we provide two Python scripts `benchOutput/performance.py` and `benchOutput/precision.py`.
The first script generated the performance graphs and the second script generates the precision graphs,
which will be saved in the `benchOutput` folder.
To run the scripts, use the commands `python3 performance.py` and `python3 precision.py` respectively.

Note that these scripts require all CSV files resulting from the performance resp. precision evaluation to be present.
In case only part of these evaluations have been run, we recommend copying the missing files
(which correspond to the parts of the evaluation that have not been executed) from `benchOutput/ase-data` to `benchOutput`.
(`benchOutput/ase-data` contains the measurements used for the graphs in the paper.)
