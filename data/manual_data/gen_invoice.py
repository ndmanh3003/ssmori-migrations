import random
from faker import Faker
from datetime import datetime, timedelta

# Initialize Faker
fake = Faker("vi_VN")

# Set to store unique phone numbers
unique_phones = set()

def generate_sql_script(start_at="2021-01-01", end_at=None):
    if end_at is None:
        end_at = datetime.now().strftime("%Y-%m-%d")

    start_date = datetime.strptime(start_at, "%Y-%m-%d")
    end_date = datetime.strptime(end_at, "%Y-%m-%d")

    branches = list(range(1, 16))  # 15 branches
    restricted_online_branches = {2, 3, 9, 14}  # Restricted branches for online orders
    online_branches = [b for b in branches if b not in restricted_online_branches]
    dishes = list(range(1, 11))  # 10 dishes
    restricted_online_dishes = {7}  # Dish 7 is restricted for online orders
    online_dishes = [d for d in dishes if d not in restricted_online_dishes]
    customers = list(range(1, 51))  # 50 customers

    sql_statements = []
    sql_statements.append("USE SSMORI\nGO\n")

    current_date = start_date

    while current_date <= end_date:
        for i in range(100):
            if i < 50:  # Offline orders
                branch_id = random.choice(branches)
                order_at = current_date.strftime("%Y-%m-%d")  
                sql_statements.append(create_offline_order(branch_id, dishes, order_at))
            elif i < 80:  # Online orders
                branch_id = random.choice(online_branches)
                customer_id = random.choice(customers)
                phone = '111'  
                address = fake.address().replace("\n", ", ")
                distance_km = random.randint(1, 10)
                order_at = current_date.strftime("%Y-%m-%d")  
                sql_statements.append(create_online_order(phone, address, distance_km, branch_id, customer_id, online_dishes, order_at))
            else:  # Reserve orders
                branch_id = random.choice(branches)
                customer_id = random.choice(customers)
                guest_count = random.randint(1, 10)
                booking_at = '2026-01-01'
                sql_statements.append(create_reserve_order(branch_id, guest_count, booking_at, customer_id))

        current_date += timedelta(days=1)  

    return "\nGO\n".join(sql_statements)

def create_offline_order(branch_id, dishes, order_at):
    sql = [
        "DECLARE @outInvoiceId INT;",
        f"EXEC sp_CreateOffOrder \n\t@invoiceId = NULL,\n\t@orderAt = '{order_at}',\n\t@customerId = NULL,\n\t@branchId = {branch_id},\n\t@outInvoiceId = @outInvoiceId OUTPUT;"
    ]
    sql.extend(add_dish_details("@outInvoiceId", dishes))
    sql.append(f"EXEC sp_SubmitOrder @invoiceId = @outInvoiceId;")
    sql.append(f"EXEC sp_PayOrder @invoiceId = @outInvoiceId;")
    return "\n".join(sql)

def create_online_order(phone, address, distance_km, branch_id, customer_id, online_dishes, order_at):
    sql = [
        "DECLARE @invoiceId INT;",
        f"EXEC sp_CreateOnlineOrder \n\t@phone = '{phone}',\n\t@address = N'{address}',\n\t@orderAt = '{order_at}',\n\t@distanceKm = {distance_km},\n\t@branchId = {branch_id},\n\t@customerId = {customer_id},\n\t@invoiceId = @invoiceId OUTPUT;"
    ]
    sql.extend(add_dish_details("@invoiceId", online_dishes))
    sql.append(f"EXEC sp_SubmitOrder @invoiceId = @invoiceId;")
    sql.append(f"EXEC sp_PayOrder @invoiceId = @invoiceId;")
    return "\n".join(sql)

def create_reserve_order(branch_id, guest_count, booking_at, customer_id):
    sql = [
        "DECLARE @invoiceId INT;",
        f"EXEC dbo.sp_CreateReserveOrder \n\t@branchId = {branch_id},\n\t@orderAt = NULL,\n\t@guestCount = {guest_count},\n\t@bookingAt = '{booking_at}',\n\t@customerId = {customer_id};"
    ]
    return "\n".join(sql)

def add_dish_details(invoice_id_var, dishes):
    selected_dishes = random.sample(dishes, 2)  
    sql = []
    for dish_id in selected_dishes:
        quantity = random.randint(1, 10)
        sql.append(f"EXEC sp_AddDetail @invoiceId = {invoice_id_var}, @dishId = {dish_id}, @quantity = {quantity};")
    return sql

script = generate_sql_script(start_at="2023-12-29")
with open("generate_invoices.sql", "w", encoding="utf-8") as f:
    f.write(script)

print("SQL script generated and saved to 'generate_invoices.sql'")
