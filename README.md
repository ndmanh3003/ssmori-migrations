## 📖 Giới thiệu dự án

Đồ án môn học **Cơ sở dữ liệu nâng cao** tại **Trường Đại học Khoa học Tự nhiên, ĐHQG-HCM (HCMUS)**.  
Đề tài của đồ án là xây dựng hệ thống quản lý cửa hàng sushi, bao gồm các nghiệp vụ như:

- Quản lý thực đơn (menu), đặt hàng (order), và thanh toán.
- Quản lý nhân sự và các chi nhánh của cửa hàng.
- Lưu trữ và xử lý dữ liệu hiệu quả bằng các kỹ thuật nâng cao như phân vùng (partitioning), chỉ mục (indexing), và trigger.
- ...daadắdvad

## 📂 Cấu trúc thư mục

```plaintext
.
├── app
│   ├── auth
│   ├── menu
│   ├── order
│   └── system
├── data
├── schemas
│   ├── jobs
│   ├── partitions
│   ├── triggers
│   ├── indexes
│   └── tables
├── test
└── utils
```

## 📋 Chi tiết từng thư mục

### `app` 📌

Thư mục chứa các chức năng chính của hệ thống, mỗi tệp được tổ chức theo module:

- **`auth`**: Xử lý xác thực người dùng và phân quyền.
- **`menu`**: Quản lý các dữ liệu menu, bao gồm mục, combo, món ăn.
- **`order`**: Xử lý các nghiệp vụ về đặt hàng, thanh toán.
- **`system`**: Quản lý thông tin hệ thống, như nhân sự và chi nhánh.

### `data` 📊

Thư mục chứa dữ liệu phục vụ cho hệ thống:

- Các file tạo dữ liệu giả lập để thử nghiệm.
- Các file tạo dữ liệu thực tế để sử dụng cho hệ thống.

### `schemas` 🗂️

Thư mục chứa định nghĩa và cấu trúc cơ sở dữ liệu:

- **`tables.sql`**: Định nghĩa và khởi tạo các bảng dữ liệu.
- **`indexes.sql`**: Cài đặt các non-clustered index để tối ưu hóa truy vấn.
- **`jobs/`**: Chứa các file định nghĩa lịch tự động cho cơ sở dữ liệu.
- **`triggers/`**: Định nghĩa trigger để quản lý tự động hóa trên các bảng.
- **`partitions/`**: Quản lý và định nghĩa phân vùng cho các bảng lớn.

### `test` 🧪

Thư mục chứa các file test được chia theo từng đợt:

- Kiểm tra chức năng của các stored procedures, triggers, indexes, và các thay đổi khác.

### `utils` 🛠️

Thư mục chứa các tiện ích và xử lý chung:

- Các function hỗ trợ thường dùng trong cơ sở dữ liệu.
- Các stored procedures phục vụ cho các nghiệp vụ không thuộc module cụ thể.
