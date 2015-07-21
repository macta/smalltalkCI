| packagesDir baselineName baselineGroup gitPath timeToRun |

packagesDir := Smalltalk argumentAt: 1.
baselineName := Smalltalk argumentAt: 2.
baselineGroup := Smalltalk argumentAt: 3.
forceUpdate := Smalltalk argumentAt: 4.
gitPath := (FileDirectory default directoryNamed: 'git_cache') fullName.

forceUpdate = 'true' ifTrue: [
  "Update Squeak image"
  Smalltalk at: #MCMcmUpdater ifPresent: [ :updater |
    timeToRun := [[ updater updateFromDefaultRepository ]
      on: Warning do: [ :ex | ex resume: true ]] timeToRun.
    Transcript cr; cr; show: '[ Time to update image: ', timeToRun, 'ms ] '; cr ]].

"If e.g. your tests change code in the image dynamically, the image will require you to set 
author initials which might fail these tests. So we set some dummy initials here to avoid this."
(Smalltalk at: #MetacelloPlatform) current authorName: 'travisCI'.

timeToRun := [ Metacello new
  baseline: baselineName;
  repository: 'filetree://', gitPath, packagesDir;
  get ] timeToRun.

Transcript cr; cr; show: '[ Time to get baseline: ', timeToRun, 'ms ] '; cr.

timeToRun := [ Metacello new
  baseline: baselineName;
  repository: 'filetree://', gitPath, packagesDir;
  load: baselineGroup ] timeToRun.

Transcript cr; cr; show: '[ Time to load baseline: ', timeToRun, 'ms ]'; cr.

"Run the tests"
timeToRun := [ MetacelloBuilderTravisCI
  runHarnessFor: { 'BaselineOf', baselineName. } ] timeToRun.

Transcript cr; cr; show: '[ Time to run tests: ', timeToRun, 'ms ]'; cr.

"Quit"
Smalltalk at: #WorldState ifPresent: [:global |
  global addDeferredUIMessage: [
    Smalltalk at: #SmalltalkImage ifPresent: [:image |
      image current
        snapshot: false
        andQuitWithExitCode: (Smalltalk at: #travisCIExitCode ifAbsent: [ 1 ]) ]]].
!