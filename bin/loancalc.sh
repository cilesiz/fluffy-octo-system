#!/bin/sh

# loancalc - Given a princepal loan amount, interest rate, and duration of 
# loan (years), calculates the per-payment amount.

# formula is: M = P * ( J / (1 -(1 + J) ** -N))
# where P = principal, J = monthly interest rate, N = duration(months)
# 
# Users typically enter P, I (annual interest rate), and L (length, years)

if [ $# -ne 3 ] ; then
	echo "Usage: $0 principal interest loan-duration-years" >&2
	exit 1
fi

P=$1	I=$2	L=$3
J="$(scriptbc -p 8 $I / \( 12 \* 100 \) )"
N="$(( $L * 12 ))"
M="$(scriptbc -p 8 $P \* \( $J / \(1 - \(1 + $J\) \^ -$N\) \) )"

# Now a little prettying up of the value:

dollars="$(echo $M | cut -d. -f1)"
cents="$(echo $M | cut -d. -f2 | cut -c1-2)"

cat << EOF 
A $L year loan at $I% interest with a principal amount of $(nicenumber $P 1 )
results in a payment of \$$dollars.$cents each month for the 
duration of the loan ($N payments).
EOF

exit 0
