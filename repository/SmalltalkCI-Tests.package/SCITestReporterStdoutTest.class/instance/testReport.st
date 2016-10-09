testing
testReport
	| runner reporter stream |
	runner := SmalltalkCI testRunnerClass runClasses: {SmalltalkCITest} named: 'SmalltalkCI'.
	stream := WriteStream on: (String new: 1000).
	reporter := SCITestReporterStdout report: runner on: stream.
	runner := SmalltalkCI testRunnerClass runClasses: {SCIExcludedTests} named: 'SmalltalkCI-Excluded'.
	self deny: runner isSuccessful