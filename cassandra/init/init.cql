-- Tạo keyspace UTF-8 (TEXT mặc định là UTF-8)
CREATE KEYSPACE IF NOT EXISTS car_retail
WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 1}
AND durable_writes = true;

USE car_retail;

-- Tạo bảng mẫu
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    name TEXT,
    email TEXT
);

-- Thêm dữ liệu mẫu
INSERT INTO users (id, name, email)
VALUES (uuid(), 'Đồng Nguyễn Thúc', 'dong@example.com');
