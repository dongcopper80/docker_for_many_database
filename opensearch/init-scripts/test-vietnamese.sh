#!/bin/bash
set -e
OS_URL="https://localhost:9200"
AUTH="admin:admin"

# Tạo index
curl -k -u $AUTH -XPUT "$OS_URL/blog_vi" -H 'Content-Type: application/json' -d '{
  "mappings": {
    "properties": {
      "title": { "type": "text", "analyzer": "vi_analyzer", "search_analyzer": "vi_analyzer" },
      "content": { "type": "text", "analyzer": "vi_analyzer", "search_analyzer": "vi_analyzer" }
    }
  }
}'

# Thêm dữ liệu
curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_doc/1" -H 'Content-Type: application/json' -d '{
  "title": "Kinh nghiệm lái xe đường dài",
  "content": "Lái xe đường dài cần chuẩn bị sức khỏe, kiểm tra lốp xe và mang theo đồ dự phòng."
}'
curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_doc/2" -H 'Content-Type: application/json' -d '{
  "title": "Bảo dưỡng xe ô tô mùa mưa",
  "content": "Kiểm tra phanh, gạt mưa và hệ thống đèn để đảm bảo an toàn."
}'
curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_doc/3" -H 'Content-Type: application/json' -d '{
  "title": "Chọn lốp xe phù hợp",
  "content": "Lốp xe phù hợp giúp tiết kiệm nhiên liệu và tăng độ bám đường."
}'

# Refresh index
curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_refresh"

# Test search
curl -k -u $AUTH -XGET "$OS_URL/blog_vi/_search" -H 'Content-Type: application/json' -d '{
  "query": { "match": { "content": "lop xe" } }
}'
