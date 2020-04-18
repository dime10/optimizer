#!/bin/bash

for file in "$@"
do
	newfile=${file%"before"}projq
	echo Processing $file ...

	(
	# strip superfluous lines, nocontrol
	sed '/Inputs.*/d' $file |
	sed '/Outputs.*/d' |
	sed '/Comment.*/d' |
	sed '/QInit0.*/d' |
	sed '/QTerm0.*/d' |
	sed '/Subroutine.*/d' |
	sed '/Shape.*/d' |
	sed '/Controllable.*/d' |
	sed '/^[[:space:]]*$/d' |
	sed -r 's:(.*) with nocontrol:\1:' |

	# substitute gate commands, ignore negative controls for now
	sed -r 's:QGate\["H"]\(([0-9]*)\) with controls=\[[+-]([0-9]*), *[+-]([0-9]*)]:C(H,2) | (q[\2], q[\3], q[\1]):' |
	sed -r 's:QGate\["H"]\(([0-9]*)\) with controls=\[[+-]([0-9]*)]:C(H,1) | (q[\2], q[\1]):' |
	sed -r 's:QGate\["H"]\(([0-9]*)\):H | q[\1]:' |

	sed -r 's:QGate\["Z"]\(([0-9]*)\) with controls=\[[+-]([0-9]*), *[+-]([0-9]*)]:C(Z,2) | (q[\2], q[\3], q[\1]):' |
	sed -r 's:QGate\["Z"]\(([0-9]*)\) with controls=\[[+-]([0-9]*)]:C(Z,1) | (q[\2], q[\1]):' |
	sed -r 's:QGate\["Z"]\(([0-9]*)\):Z | q[\1]:' |

	sed -r 's:QGate\["T"]\*\(([0-9]*)\) with controls=\[[+-]([0-9]*), *[+-]([0-9]*)]:C(Tdag,2) | (q[\2], q[\3], q[\1]):' |
	sed -r 's:QGate\["T"]\*\(([0-9]*)\) with controls=\[[+-]([0-9]*)]:C(Tdag,1) | (q[\2], q[\1]):' |
	sed -r 's:QGate\["T"]\*\(([0-9]*)\):Tdag | q[\1]:' |
	sed -r 's:QGate\["T"]\(([0-9]*)\) with controls=\[[+-]([0-9]*), *[+-]([0-9]*)]:C(T,2) | (q[\2], q[\3], q[\1]):' |
	sed -r 's:QGate\["T"]\(([0-9]*)\) with controls=\[[+-]([0-9]*)]:C(T,1) | (q[\2], q[\1]):' |
	sed -r 's:QGate\["T"]\(([0-9]*)\):T | q[\1]:' |

	sed -r 's:QGate\["S"]\*\(([0-9]*)\) with controls=\[[+-]([0-9]*), *[+-]([0-9]*)]:C(Sdag,2) | (q[\2], q[\3], q[\1]):' |
	sed -r 's:QGate\["S"]\*\(([0-9]*)\) with controls=\[[+-]([0-9]*)]:C(Sdag,1) | (q[\2], q[\1]):' |
	sed -r 's:QGate\["S"]\*\(([0-9]*)\):Sdag | q[\1]:' |
	sed -r 's:QGate\["S"]\(([0-9]*)\) with controls=\[[+-]([0-9]*), *[+-]([0-9]*)]:C(S,2) | (q[\2], q[\3], q[\1]):' |
	sed -r 's:QGate\["S"]\(([0-9]*)\) with controls=\[[+-]([0-9]*)]:C(S,1) | (q[\2], q[\1]):' |
	sed -r 's:QGate\["S"]\(([0-9]*)\):S | q[\1]:' |

	sed -r 's:QGate\["not"]\(([0-9]*)\) with controls=\[[+-]([0-9]*), *[+-]([0-9]*)]:C(X,2) | (q[\2], q[\3], q[\1]):' |
	sed -r 's:QGate\["not"]\(([0-9]*)\) with controls=\[[+-]([0-9]*)]:C(X,1) | (q[\2], q[\1]):' |
	sed -r 's:QGate\["not"]\(([0-9]*)\):X | q[\1]:' |

	# substitute rotation gates
	sed -r 's:QRot\["exp\(-i%Z\)",([-.0-9e]*)]\(([0-9]*)\):R(\1) | q[\2]:'
	) > $newfile

	echo Done processing. Saved converted circuit in $newfile.
	echo Missing:
	grep -vE '^X |^C\(|^H |^Z |^S |^Sdag |^T |^Tdag |^R\(' $newfile
	echo
done
