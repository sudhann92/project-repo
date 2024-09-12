#!/usr/bin/python
import sys
from dateutil.parser import parse
import re
def run_module():
    # Module arguments
    date_value = sys.argv[1].strip()
    date_format = sys.argv[2].strip()
    patter_val = '^([0-9]{4})-([0-9][1-9]|1[0-2])-([0-9]{2})$'
    replace_val = date_value.replace("/", "-").replace("_", "-")
    if re.search(patter_val, replace_val):
       dat = parse(replace_val, yearfirst=True)
       print(dat.date().strftime(date_format))
    else:
      dat = parse(replace_val, dayfirst=True)
      print(dat.date().strftime(date_format))

def main():
    run_module()

if __name__ == "__main__":
    main()
