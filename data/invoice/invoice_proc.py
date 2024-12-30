import random
from datetime import datetime, timedelta

branches = list(range(1, 16)) 
restricted_online_branches = {2, 3, 9, 14} 
online_branches = [b for b in branches if b not in restricted_online_branches]

dishes = list(range(1, 11))
restricted_online_dishes = {7}
online_dishes = [d for d in dishes if d not in restricted_online_dishes]

customers = list(range(1, 51))
    
def generate_sql_script(start_at="2024-12-1", end_at="2024-12-30"):
    start_date = datetime.strptime(start_at, "%Y-%m-%d")
    end_date = datetime.strptime(end_at, "%Y-%m-%d")

    sql_statements = []
    sql_statements.append("USE SSMORI")

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
                address = '123 Main St'
                distance_km = random.randint(1, 10)
                order_at = current_date.strftime("%Y-%m-%d")  
                sql_statements.append(create_online_order(phone, address, distance_km, branch_id, customer_id, online_dishes, order_at))
                
            else:  # Reserve orders
                branch_id = random.choice(branches)
                customer_id = random.choice(customers)
                guest_count = 5
                booking_at = '2026-01-01'
                order_at = current_date.strftime("%Y-%m-%d")
                sql_statements.append(create_reserve_order(branch_id, guest_count, booking_at, order_at, customer_id)), 

        current_date += timedelta(days=1)  

    return "\nGO\n\n".join(sql_statements)

def create_offline_order(branch_id, dishes, order_at):
    sql = [
        "DECLARE @outInvoiceId INT;",
        f"EXEC dbo.sp_CreateOffOrder  @orderAt = '{order_at}', @branchId = {branch_id}, @outInvoiceId = @outInvoiceId OUTPUT;"
    ]
    sql.extend(add_dish_details("@outInvoiceId", dishes))
    sql.append(f"EXEC dbo.sp_SubmitOrder @invoiceId = @outInvoiceId;")
    sql.append(f"EXEC dbo.sp_PayOrder @invoiceId = @outInvoiceId;")
    return "\n".join(sql)

def create_online_order(phone, address, distance_km, branch_id, customer_id, online_dishes, order_at):
    sql = [
        "DECLARE @invoiceId INT;",
        f"EXEC dbo.sp_CreateOnlineOrder  @phone = '{phone}', @address = N'{address}', @orderAt = '{order_at}', @distanceKm = {distance_km}, @branchId = {branch_id}, @customerId = {customer_id}, @invoiceId = @invoiceId OUTPUT;"
    ]
    sql.extend(add_dish_details("@invoiceId", online_dishes))
    sql.append(f"EXEC dbo.sp_SubmitOrder @invoiceId = @invoiceId;")
    sql.append(f"EXEC dbo.sp_PayOrder @invoiceId = @invoiceId;")
    return "\n".join(sql)

def create_reserve_order(branch_id, guest_count, booking_at, order_at, customer_id):
    sql = [
        "DECLARE @invoiceId INT;",
        f"EXEC dbo.sp_CreateReserveOrder  @branchId = {branch_id}, @orderAt = '{order_at}', @guestCount = {guest_count}, @bookingAt = '{booking_at}', @customerId = {customer_id}, @invoiceId = @invoiceId OUTPUT;\n"
        "DECLARE @outInvoiceId INT;",
        f"EXEC dbo.sp_CreateOffOrder  @invoiceId = @invoiceId, @outInvoiceId = @outInvoiceId OUTPUT;"
    ]
    sql.extend(add_dish_details("@outInvoiceId", dishes))
    sql.append(f"EXEC dbo.sp_SubmitOrder @invoiceId = @outInvoiceId;")
    sql.append(f"EXEC dbo.sp_PayOrder @invoiceId = @outInvoiceId;")
    return "\n".join(sql)

def add_dish_details(invoice_id_var, dishes):
    selected_dishes = random.sample(dishes, 2)  
    sql = []
    for dish_id in selected_dishes:
        quantity = random.randint(1, 3)
        sql.append(f"EXEC dbo.sp_AddDetail @invoiceId = {invoice_id_var}, @dishId = {dish_id}, @quantity = {quantity};")
    return sql

script = generate_sql_script(start_at="2020-1-1", end_at="2020-1-28")

with open("invoice_proc.sql", "w", encoding="utf-8") as f:
    f.write(script + "\nGO")

print("🎇🎇 SQL script generated successfully 🎇🎇")