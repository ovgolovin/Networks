#!/usr/bin/env bash

trap "kill 0" SIGINT SIGTERM EXIT  # kill all subshells on exit

function display_help {
	echo "Simple proxy."
	echo "Expects one parameter: port number."
	echo "If not specified, the default port number 6000 is assumed."
}

for parameter in "$@"
do
	if [ "$parameter" == "--help" ]
	then
		display_help
		exit
	fi
done



if [ "$#" -eq 1 ]
then
	port="$1"
elif [ "$#" -eq 0 ]
then
	port="6000"
else
	echo "Wrong number of parameters"
	display_help
	exit
fi
	

while true # infinite loop to await connection from client
do

echo "OK!"

rm -f client_output client_output_for_request_forming server_output
mkfifo client_output client_output_for_request_forming server_output  # create named pipes

# creating subshell
(
	cat <server_output |
	nc -lp $port |  # awaiting connection from the client of the port specified
	tee client_output_for_request_forming | # sending copy of ouput to client_output_for_request_forming pipe
	tee client_output  # sending copy of ouput to client_output pipe
) &   # starting subshell in a separate process



# creating another subshell (to feed client_output_for_request_forming to it)
(
	while read line;  # read input from client_output_for_request_forming line by line
	do
		echo "line read: $line"
		if [[ $line =~ ^Host:[[:space:]]([[:alnum:]._-]+)(:([[:digit:]]+))?$ ]]
		then
			echo "match: $line"
			server_port=${BASH_REMATCH[3]}  # extracting server port from regular expression
			if [[ "$server_port" -eq "" ]]
			then
				server_port="80"
			fi
			host=${BASH_REMATCH[1]}  # extracting host from regular expression
			nc $host $server_port <client_output |  # connect to the server
			tee server_output  # send copy to server_output pipe
			break
		fi
	done
		
) <client_output_for_request_forming


rm -f client_output client_output_for_request_forming server_output

done
