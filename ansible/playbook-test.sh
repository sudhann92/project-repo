ansible-playbook --check ssl_creation/playbook.yml  -e "csr_create_unique_name='ip-172-31-91-171' csr_create_cn='ec2_test.rhb'" >test.output 2>&1 || true 
if grep -q 'unreachable=0.*failed=0' test.output
then
  echo "Playbook $1 executed without issues."
else
  echo "Playbook $1 failed to run:"
  cat test.output
  exit 1
fi
