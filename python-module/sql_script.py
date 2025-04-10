import os
import re
import glob
import subprocess
from datetime import datetime, timedelta


# ✅ Step 5: Define Functions for SQL Processing
def parse_create_table_statements(sql_dump):
    """Extract column names from CREATE TABLE statements."""
    tables = {}
    create_table_pattern = re.compile(r'CREATE TABLE `(\w+)` \((.*?)\)\sENGINE=', re.S)

    for match in create_table_pattern.finditer(sql_dump):
        table_name = match.group(1)
        columns_part = match.group(2)

        # Extract column names (ignore constraints)
        columns = []
        column_lines = columns_part.split("\n")

        for line in column_lines:
            column_match = re.match(r'\s*`(\w+)`\s', line)  # Match column names only
            if column_match:
                columns.append(column_match.group(1))

        if columns:
            tables[table_name] = columns

    return tables


def modify_insert_statements(sql_dump, table_columns):
    """Modify INSERT statements to include column names and ON DUPLICATE KEY UPDATE."""
    modified_dump = []
    insert_pattern = re.compile(r'INSERT INTO `(\w+)` VALUES')

    for line in sql_dump.split("\n"):
        match = insert_pattern.search(line)
        if match:
            table_name = match.group(1)
            if table_name in table_columns:
                column_names = ",".join(f"`{col}`" for col in table_columns[table_name])
                update_part = ",".join(f"`{col}`=VALUES(`{col}`)" for col in table_columns[table_name])

                # Modify the insert statement properly
                line = re.sub(r'INSERT INTO `(\w+)` VALUES',
                              f'INSERT INTO `{table_name}` ({column_names}) VALUES',
                              line)[:-1] + f" ON DUPLICATE KEY UPDATE {update_part};"

        modified_dump.append(line)

    return "\n".join(modified_dump)


def remove_drop_create_statements(sql_dump):
    """Remove CREATE DATABASE, DROP TABLE, and CREATE TABLE blocks."""
    # Remove CREATE DATABASE command
    sql_dump = re.sub(r'CREATE DATABASE .*?latin1.*?;', '', sql_dump, flags=re.S)

    # Remove all DROP TABLE lines
    sql_dump = re.sub(r'DROP TABLE IF EXISTS `\w+`;[\r\n]*', '', sql_dump)

    # Remove entire CREATE TABLE blocks
   # sql_dump = re.sub(r'CREATE TABLE `\w+` \([\s\S]*?latin1;[\r\n]*', '', sql_dump)
    sql_dump = re.sub(r'CREATE TABLE `\w+` \([\s\S]*?\)\s+ENGINE=\w+.*?CHARSET=\w+.*?;', '', sql_dump)

    return sql_dump


def analyze_all_tables(mysql_user, mysql_password, mysql_db):
    # Fetch all table names
    fetch_tables_command = f"mysql -u {mysql_user} -p'{mysql_password}' -D {mysql_db} -se 'SHOW TABLES';"
    tables_output = subprocess.run(fetch_tables_command, shell=True, capture_output=True, text=True)

    if tables_output.returncode == 0:
        tables = tables_output.stdout.strip().split("\n")
        print(f"✅ Found {len(tables)} tables. Running ANALYZE TABLE...")

        for table in tables:
            analyze_command = f"mysql -u {mysql_user} -p'{mysql_password}' -D {mysql_db} -e \"ANALYZE TABLE {table};\" > /dev/null 2>&1"
            subprocess.run(analyze_command, shell=True, check=True)
        print("✅ ANALYZE TABLE completed for all tables in GNOCMON! 🚀")
    else:
        print("❌ Failed to fetch table names!")


def main():

        # ✅ Step 6: Load SQL File and Process It
        with open(sql_dump_file, "r", encoding="utf-8") as file:
            sql_content = file.read()

        # Step 7: Extract table structures
        table_columns = parse_create_table_statements(sql_content)

        # Step 8: Modify INSERT statements
        modified_sql = modify_insert_statements(sql_content, table_columns)

        # Step 9: Remove DROP TABLE and CREATE TABLE statements
        cleaned_sql = remove_drop_create_statements(modified_sql)

        # ✅ Step 10: Save the Final Cleaned SQL File
        final_output_dir = "/data/mysql_backup/mysql_final_dump/"
        os.makedirs(final_output_dir, exist_ok=True)

        final_sql_dump_file = os.path.join(final_output_dir, f"final_modified_dump-{yesterday_date}.sql")
        with open(final_sql_dump_file, "w", encoding="utf-8") as file:
            file.write(cleaned_sql)

        print(f"✅ Final cleaned SQL saved as: {final_sql_dump_file}")

        load_command = f"mysql -u {mysql_user} -p'{mysql_password}' < {final_sql_dump_file}"
        subprocess.run(load_command, shell=True, check=True)


        print("SQL has been successfully imported into MySQL! 🎉")

        # Run the function
        analyze_all_tables(mysql_user, mysql_password, mysql_db)


        print("🔥 All steps completed successfully! GNOCMON is fully optimized! 💪")
        print("------------------MYSQL SYNC LOG ENDED",datetime.today(),"---------------------\n")



if __name__ == "__main__":


    print("------------------MYSQL SQL LOG STARTED",datetime.today(),"---------------------\n")
    # ✅ Step 1: Get Yesterday's Date (for file matching)
    yesterday_date = (datetime.today() - timedelta(days=1)).strftime('%m-%d-%Y')

    # ✅ Step 2: Find the Latest `.tar.gz` File in `/data/mysql_backup/`
    backup_dir = "/data/mysql_backup/"
    backup_dump_dir="/data/mysql_backup/home/newsuperuser/backup/autodelete/"
    backup_filename_pattern = f"InfraNetMysql_GNOCMON_{yesterday_date}.tar.gz"
    backup_file = os.path.join(backup_dir, backup_filename_pattern)
    mysql_user = "root"
    mysql_password = "DigitalTwin2025!"
    mysql_db="GNOCMON"

    if not os.path.exists(backup_file):
        print(f"❌ Backup file {backup_file} not found!")
        exit(1)

    print(f"✅ Found Backup File: {backup_file}")

    # ✅ Step 3: Extract the `.tar.gz` File
    extract_command = f"tar -xzf {backup_file} -C {backup_dir}"
    subprocess.run(extract_command, shell=True, check=True)

    # ✅ Step 4: Locate the `.sql` Dump File
    sql_dump_file = os.path.join(backup_dump_dir, "InfraNetMysql_GNOCMON.sql")
    if not os.path.exists(sql_dump_file):
        print("❌ SQL dump file not found after extraction!")
        exit(1)

    print(f"✅ Extracted SQL Dump: {sql_dump_file}")
    main()

