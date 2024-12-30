import os
import random
import shutil
from datetime import datetime, timedelta

month = 0

def generate_invoices(start_month: str, end_month: str):
    global month 
    
    start_date = datetime.strptime(start_month, "%m/%Y")
    end_date = datetime.strptime(end_month, "%m/%Y")

    if start_date > end_date:
        raise ValueError("Error: Start month must be before end month")

    current_date = start_date

    if os.path.exists("insert"):
        shutil.rmtree("insert")
        
    os.makedirs("insert")

    while current_date <= end_date:
        current_year = current_date.year
        current_month = current_date.month

        output_file = f"insert/insert_{current_year}.sql"
        
        with open(output_file, "a", encoding="utf-8") as outfile:
            
            outfile.write("USE [SSMORI] \nGO \nALTER TABLE StaticsRevenueDate DISABLE TRIGGER ALL; \nALTER TABLE Invoice NOCHECK CONSTRAINT ALL; \nALTER TABLE InvoiceDetail NOCHECK CONSTRAINT ALL; \nALTER TABLE InvoiceReserve NOCHECK CONSTRAINT ALL; \nALTER TABLE InvoiceOnline NOCHECK CONSTRAINT ALL; \nALTER TABLE StaticsRevenueDate NOCHECK CONSTRAINT ALL; \nALTER TABLE StaticsDishMonth NOCHECK CONSTRAINT ALL; \nALTER TABLE StaticsRevenueMonth NOCHECK CONSTRAINT ALL;\nGO\n")
            
            while current_date.year == current_year and current_date <= end_date:
                month_str = current_date.strftime("%Y-%m")

                sample_file = f"sample/{random.randint(1, 4)}.sql"

                with open(sample_file, "r", encoding="utf-8") as infile:
                    content = infile.read()
                    content = content.replace("2020-01", month_str)
                    
                    lines = content.splitlines()
                    for i in range(len(lines)):
                        if "[invoice]" in lines[i] or "[id]" in lines[i]:
                            start_pos = lines[i].find("VALUES (") + len("VALUES (")
                            end_pos = lines[i].find(",", start_pos)
                            
                            if start_pos != -1 and end_pos != -1:
                                value = int(lines[i][start_pos:end_pos].strip())
                                new_value = value + 2800 * month
                                lines[i] = lines[i][:start_pos] + str(new_value) + lines[i][end_pos:]
                    
                    content = "\n".join(lines)

                outfile.write(content + "\n")

                month += 1

                if current_month == 12:
                    current_date = datetime(current_year + 1, 1, 1)
                else:
                    current_date = datetime(current_year, current_month + 1, 1)
                current_month = current_date.month
                
            outfile.write("ALTER TABLE StaticsRevenueDate ENABLE TRIGGER ALL; \nALTER TABLE Invoice WITH CHECK CHECK CONSTRAINT ALL; \nALTER TABLE InvoiceDetail WITH CHECK CHECK CONSTRAINT ALL; \nALTER TABLE InvoiceReserve WITH CHECK CHECK CONSTRAINT ALL; \nALTER TABLE InvoiceOnline WITH CHECK CHECK CONSTRAINT ALL; \nALTER TABLE StaticsRevenueDate WITH CHECK CHECK CONSTRAINT ALL; \nALTER TABLE StaticsDishMonth WITH CHECK CHECK CONSTRAINT ALL; \nALTER TABLE StaticsRevenueMonth WITH CHECK CHECK CONSTRAINT ALL;\nGO")

if __name__ == "__main__":
    start_month = input("Start month (mm/yyyy): ") or "01/2022"
        
    end_month = input("End month (mm/yyyy): ") or (datetime.now().replace(day=1) - timedelta(days=1)).strftime("%m/%Y")

    try:
        generate_invoices(start_month, end_month)
        print("🎇🎇 SQL scripts generated successfully 🎇🎇")
    except Exception as e:
        print(f"Error: {e}")
