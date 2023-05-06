#!/bin/bash


### TODO

# Remove FILES IF EMPTY 

## requirements ?

INPUT_FILE=$1;
OUTPUT_DIR=$2;
USAGE_AUX="Please provide only 2 arguments. Input .eml file and Output directory.
	For more information, please check -h option.";
Help (){
	echo "Usage: ./analyze.sh [input .eml file] [output directory path]
	
	-h, --help: This message and exits.";
	exit 0;
}


Check_input_file (){
	# TODO: check magic numbers?
	if [[ ! -s "$INPUT_FILE"  && ! "$INPUT_FILE" = "*.eml" ]]
	then
		echo "The file does not exist or is not an .eml file.";
		exit 1;
	fi
}

Check_output_dir (){
	if [[ ! -d "$OUTPUT_DIR" ]]
	then
		echo "The directory does not exist".;
		exit 1;
	elif [[ ! -w "$OUTPUT_DIR" ]]
	then
		echo "You cant write in that directory.";
		exit 1;
	fi
}

Email_analyzer (){
	# headers
	python3 EmailAnalyzer/email-analyzer.py -H -f $INPUT_FILE > $OUTPUT_DIR/headers.txt;

	# digests
	python3 EmailAnalyzer/email-analyzer.py -d -f $INPUT_FILE > $OUTPUT_DIR/digests.txt;

	# URL links
	python3 EmailAnalyzer/email-analyzer.py -l -f $INPUT_FILE > $OUTPUT_DIR/links_temp.txt;

	cat $OUTPUT_DIR/links_temp.txt | grep http | awk -F['->'] '{print $3}' > $OUTPUT_DIR/urls.txt;
	cat $OUTPUT_DIR/links_temp.txt | grep mailto | awk -F[':'] '{print $2}' > $OUTPUT_DIR/mails.txt;
	rm $OUTPUT_DIR/links_temp.txt;

	# Attachments
	python3 EmailAnalyzer/email-analyzer.py -a -f $INPUT_FILE | grep ] | awk -F['->'] '{print $3}' > $OUTPUT_DIR/attachments.txt;
	if [[ ! -s "$OUTPUT_FILE/attachments.txt" ]]
	then
		echo "We recomend you to use tools such \"binwalk\" or \"strings\" to obtain more information about the attachments.";
	fi
	echo "Script finished. You can find the reports in $OUTPUT_DIR/*.";
	exit 0;
}	

if [ $# -eq 0 ]
then
	echo "No arguments supplied, ";
	exit 1;
elif [[ $# -eq 1 && ( "$1" = "-h" || "$1" = "--help" )]]
then
	Help;
	exit 0;
elif [ $# -eq 2 ]
then
	Check_input_file;
	Check_output_dir;
	Email_analyzer;
else
	echo $USAGE_AUX;
	exit 1;
fi





