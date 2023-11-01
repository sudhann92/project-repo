Role Name
=========

[![ssl_role](https://github.com/sudhann92/project-repo/tree/new_branch/ssl_creation/roles/ssl_role)]

Created the SSL role used to generate the CSR creation automatically

``` Example
ansible-playbook playbook.yml -e 'csr_create_unique_name=sshcds01 csr_create_cn=xxx.google.com'
```

Requirements
------------

```bash
ansible-galaxy collection install community.crypto
```
To run this playbook need to install the crypto collection

Role Variables
--------------
Madantory Variable need to pass while executing the playbook
```
      - csr_create_unique_name = 'Any name'
      - csr_create_cn = 'Put the common name or server name' 
```


Dependencies
------------
```
python 3 above
ansible controller server
crypto collection
```
License
-------

[!Sudhan]

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
