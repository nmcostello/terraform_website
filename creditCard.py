# Enter your code here. Read input from STDIN. Print output to STDOUT
import re
import sys
 
# Iterate through stdin
for count, line in enumerate(sys.stdin):
    # skip first input, because it's the length of inputs
    if count == 0:
        continue
    # match the line
    search = re.match(r"(^[4-6][0-9]{3})(-{0,1}([0-9]){4}){3}$", line)
    
    # if the line was a match then check for repeats
    if search:
        # replace dashes with empty
        line = line.replace("-", "")
        repeat = re.match(r"((\d)(?!\2{3})){16}$", line)
        # if it's a valid number and there are no repeats print Valid
        if repeat:
            print("Valid")
        else:
            print("Invalid")
    else:
        print("Invalid")
