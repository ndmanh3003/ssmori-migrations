import csv
import os

def csv_to_sql_insert(file_paths):
    """
    Convert multiple CSV files to SQL INSERT statements for different tables.

    :param file_paths: List of paths to the CSV files.
    :return: A string containing SQL INSERT statements.
    """
    insert_statements = []
    identity_list = ['Region', 'Branch', 'Card', 'Dish', 'Customer', 'Category', 'Invoice']

    for file_path in reversed(file_paths):
        table_name = os.path.splitext(os.path.basename(file_path))[0]
        insert_statements.append(f"DELETE FROM {table_name};")
    # Add DELETE and DBCC CHECKIDENT for all tables first
    for file_path in file_paths:
        table_name = os.path.splitext(os.path.basename(file_path))[0]  # Use file name (without extension) as table name
        if table_name in identity_list:
            insert_statements.append(f"DBCC CHECKIDENT ('{table_name}', RESEED, 0);")
        
    insert_statements.append(f"GO")

    for file_path in file_paths:
        table_name = os.path.splitext(os.path.basename(file_path))[0]  # Use file name (without extension) as table name
        if table_name in identity_list:
            insert_statements.append(f"SET IDENTITY_INSERT {table_name} ON")
        
        with open(file_path, mode='r', encoding='utf-8-sig') as file:
            reader = csv.reader(file)
            headers = next(reader)  # Read the first row as column names

            for row in reader:
                values = []
                for value in row:
                    if value.isdigit():
                        values.append(value)  # Keep integers as-is
                    elif value.replace('.', '', 1).isdigit():
                        values.append(value)  # Keep floats as-is
                    elif value.lower() in ['true', 'false']:  # Handle boolean values
                        values.append('1' if value.lower() == 'true' else '0')
                    elif value == 'NULL' or value == 'null':
                        values.append('NULL')  # Handle NULL values
                    else:
                        escaped_value = value.replace("'", "''")  # Escape single quotes
                        values.append(f"N'{escaped_value}'")

                insert_statement = f"INSERT INTO {table_name} ({', '.join(headers)}) VALUES ({', '.join(values)});"
                insert_statements.append(insert_statement)

        # Add GO at the end of the statements for this table
        if table_name in identity_list:
            insert_statements.append(f"SET IDENTITY_INSERT {table_name} OFF")
        insert_statements.append("GO")

    return '\n'.join(insert_statements)


# Example usage
file_paths = ['Region.csv', 'Branch.csv', 'Category.csv', 'Dish.csv', 'CategoryDish.csv', 'ComboDish.csv']  # List of your CSV files
sql_statements = csv_to_sql_insert(file_paths)

# Save the output to a file or print it
with open('output.sql', 'w', encoding='utf-8') as output_file:
    output_file.write(sql_statements)

print("SQL INSERT statements for multiple files have been generated and saved to output.sql.")
