import cx_Oracle

# Connect as user "hr" with password "welcome" to the "orclpdb1" service running on this computer.
connection = cx_Oracle.connect(user="VMMM", password="xxxxxxxx",
                               dsn="corp.local/<service name>")

cursor = connection.cursor()
cursor.execute("select distinct subtask_id from vmp_main where subtask_id is not null and vmp_risk_exp < sysdate-1")
for fname in cursor:
    print("Values:", fname)
