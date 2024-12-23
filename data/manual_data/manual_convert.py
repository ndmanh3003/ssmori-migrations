import csv
from pathlib import Path

def sort_files(file_paths):
    """
    Sort file paths based on predefined order, followed by alphabetical order for the rest.
    """
    priority_order = [
        'region.csv', 'branch.csv', 'customer.csv', 'card.csv',
        'dish.csv', 'category.csv', 'invoice.csv', 'review.csv', 'const.csv'
    ]
    
    def file_key(file_path):
        file_name = file_path.name.lower()  # Lấy tên file (không phân biệt chữ hoa/thường)
        if file_name in priority_order:
            return (0, priority_order.index(file_name))  # Ưu tiên theo thứ tự được định nghĩa
        return (1, file_name)  # Các file còn lại theo thứ tự alphabet

    return sorted(file_paths, key=file_key)

def csv_to_sql_insert(file_paths):
    """
    Convert multiple CSV files to SQL INSERT statements with line breaks between values.
    """
    insert_statements = []
    identity_list = ['Region', 'Branch', 'Card', 'Dish', 'Customer', 'Category', 'Invoice']
    
    insert_statements.append("USE SSMORI\nGO\n")

    for file_path in reversed(file_paths):
        table_name = file_path.stem  # Lấy tên tệp mà không có phần mở rộng
        insert_statements.append(f"DELETE FROM {table_name};")
    insert_statements.append("GO\n")

    for file_path in file_paths:
        table_name = file_path.stem  # Lấy tên tệp mà không có phần mở rộng
        if table_name in identity_list:
            insert_statements.append(f"DBCC CHECKIDENT ('{table_name}', RESEED, 0);")
    insert_statements.append("GO\n")

    for file_path in file_paths:
        table_name = file_path.stem  # Lấy tên tệp mà không có phần mở rộng
        
        with file_path.open(mode='r', encoding='utf-8-sig') as file:  # Mở tệp bằng pathlib
            reader = csv.reader(file)
            headers = next(reader)
            
            value_groups = []
            for row in reader:
                values = []
                for value in row:
                    if value.isdigit():
                        values.append(value)
                    elif value.replace('.', '', 1).isdigit():
                        values.append(value)
                    elif value.lower() in ['true', 'false']:
                        values.append('1' if value.lower() == 'true' else '0')
                    elif value == 'NULL' or value == 'null':
                        values.append('NULL')
                    else:
                        escaped_value = value.replace("'", "''")
                        values.append(f"N'{escaped_value}'")
                value_groups.append(f"({', '.join(values)})")

            if value_groups:
                insert_statement = f"INSERT INTO {table_name} ({', '.join(headers)}) VALUES \n"
                insert_statement += ',\n'.join(value_groups) + ";"
                insert_statements.append(insert_statement)
        
        insert_statements.append("GO\n")

    return '\n'.join(insert_statements)

# Tự động lấy tất cả tệp CSV trong thư mục hiện tại
current_dir = Path(__file__).resolve().parent  # Thư mục chứa script hiện tại
file_paths = list(current_dir.glob('*.csv'))  # Lấy tất cả tệp .csv trong thư mục
file_paths = sort_files(file_paths)

sql_statements = csv_to_sql_insert(file_paths)

with open('output.sql', 'w', encoding='utf-8') as output_file:
    output_file.write(sql_statements)

print("SQL INSERT statements have been generated and saved to output.sql.")
