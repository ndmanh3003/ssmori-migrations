from faker import Faker
import pandas as pd

# Khởi tạo đối tượng Faker
fake = Faker()

# Hàm tạo dữ liệu cho bảng Users
def generate_users(num=1000):
    users = []
    email_set = set()
    for i in range(num):
        email = fake.email()
        while email in email_set:  # Đảm bảo không có email trùng lặp
            email = fake.email()
        email_set.add(email)
        users.append({
            'id': i + 1,  # ID người dùng bắt đầu từ 1
            'email': email,
            'name': fake.name(),
        })
    return pd.DataFrame(users)

# Hàm tạo dữ liệu cho bảng Posts
def generate_posts(users_df, num=100000):
    posts = []
    for i in range(num):
        # Chọn ngẫu nhiên ID của người dùng
        user_id = fake.random_element(users_df['id'])
        posts.append({
            'id': i + 1,  # ID bài đăng bắt đầu từ 1
            'title': fake.sentence(),
            'user_id': user_id,  # Liên kết với người dùng có ID tương ứng
        })
    return pd.DataFrame(posts)

# Tạo dữ liệu
users_df = generate_users()
posts_df = generate_posts(users_df)

# Lưu vào file CSV (hoặc có thể xuất vào SQL)
users_df.to_csv('users.csv', index=False)
posts_df.to_csv('posts.csv', index=False)

# In một số dữ liệu mẫu
print(users_df.head())
print(posts_df.head())
