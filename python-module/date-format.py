#!/usr/bin/python

# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: date_convert_format

short_description: Convert the date format into desired format


# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This description explaining date convert format module.

options:
    date_value:
        description: This is the message to get the date value from args.
        required: true
        type: str
    date_format:
        description:
            - This args used to convert the given date value to certain format.
            - Parameter description can be a string.
        required: false
        type: str
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
extends_documentation_fragment:
    - my_namespace.my_collection.my_doc_fragment_name

author:
    - Sudhan
'''

EXAMPLES = r'''
# Pass in a message
- name: Test with a message
  date_convert_format:
      date_value: "02.03.2022"
      date_format: "%d-%^b-%Y"
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: '02-03-2022'
message:
    description: The output message that the date convert module generates.
    type: str
    sample: '02-MAR-2022'
'''

from ansible.module_utils.basic import AnsibleModule
from dateutil.parser import parse
import re


def run_date_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        date_value=dict(type='str', required=True),
        date_format=dict(type='str', required=False, default="%d-%^b-%Y")
    )

    # seed the result dict in the object
    # changed is if this module effectively modified the target
    result = dict(
        changed=False,
        original_message='',
        message=''
    )

    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(**result)


    # If the give date like alpha or numeric value means it will get failed
    # AnsibleModule.fail_json() to pass in the message and the result
    
    
    if module.params['date_value'] is None or len(module.params['date_value']) == 0:
        module.fail_json(msg='date_value should not be Empty', **result)

    if module.params['date_value'].isalnum():
        module.fail_json(msg="Date Value Should Be Separate With Following Any One Special Char ['-','.','/']", **result)

    #Based on date value input convert the value to desired format
    #imported the parse library from dateutils and imported re for search and replace value
    def result_val():
    result['changed'] = True
    result['original_message'] = date_value_var
    result['converted_format'] = convert_val
    result['message'] = 'Given Date Format has converted as desired Format'

    if module.params['date_value'] is not None:
        date_value_var = module.params['date_value']
        pattern_val = '^([0-9]{4})-([0-9][1-9]|1[0-2])-([0-9]{2})$'
        replace_val = date_value_var.replace("/", "-").replace("_", "-").replace(".", "-")
        
        if re.search(pattern_val, replace_val):
            date_val = parse(replace_val, yearfirst=True)
            convert_val = date_val.date().strftime(module.params['date_format'])
            result_val()

        else:
            date_val = parse(replace_val, dayfirst=True)
            convert_val = date_val.date().strftime(module.params['date_format'])
            result_val()

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result


    # In the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    module.exit_json(**result)



def main():
    run_date_module()


if __name__ == '__main__':
    main()
