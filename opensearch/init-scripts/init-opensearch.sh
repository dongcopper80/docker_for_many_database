#!/bin/bash
set -e

OS_URL="https://opensearch-node1:9200"
DASH_URL="http://opensearch-dashboards:5601"
AUTH="admin:admin"

echo "⏳ Đợi OpenSearch sẵn sàng..."
until curl -k -s -u $AUTH "$OS_URL/_cluster/health" | grep -q '"status":"green"'; do
  sleep 5
done
echo "✅ OpenSearch OK"

echo "=== Tạo index blog_vi với Analyzer + Suggestion ==="
curl -k -u $AUTH -XPUT "$OS_URL/blog_vi" -H 'Content-Type: application/json' -d '{
  "settings": {
    "analysis": {
      "analyzer": {
        "vi_analyzer": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "stop", "asciifolding"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": { "type": "text", "analyzer": "vi_analyzer" },
      "content": { "type": "text", "analyzer": "vi_analyzer" },
      "suggest": { "type": "completion", "analyzer": "vi_analyzer" }
    }
  }
}'

echo "=== Thêm dữ liệu mẫu ==="
curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_doc" -H 'Content-Type: application/json' -d '{
  "title": "Kinh nghiệm lái xe đường dài",
  "content": "Lái xe đường dài cần chuẩn bị sức khỏe, kiểm tra lốp xe và mang theo đồ dự phòng.",
  "suggest": ["lái xe", "kinh nghiệm lái xe"]
}'
curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_doc" -H 'Content-Type: application/json' -d '{
  "title": "Bảo dưỡng xe ô tô mùa mưa",
  "content": "Kiểm tra phanh, gạt mưa và hệ thống đèn để đảm bảo an toàn.",
  "suggest": ["bảo dưỡng xe", "bảo dưỡng ô tô"]
}'
curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_doc" -H 'Content-Type: application/json' -d '{
  "title": "Chọn lốp xe phù hợp",
  "content": "Lốp xe phù hợp giúp tiết kiệm nhiên liệu và tăng độ bám đường.",
  "suggest": ["lốp xe", "chọn lốp xe"]
}'

curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_refresh"

echo "=== Test tìm kiếm với highlight ==="
curl -k -u $AUTH -XGET "$OS_URL/blog_vi/_search" -H 'Content-Type: application/json' -d '{
  "query": { "match": { "content": "lop xe" } },
  "highlight": {
    "fields": {
      "content": {},
      "title": {}
    }
  }
}'

echo "=== Test gợi ý từ khóa ==="
curl -k -u $AUTH -XPOST "$OS_URL/blog_vi/_search" -H 'Content-Type: application/json' -d '{
  "suggest": {
    "blog-suggest": {
      "prefix": "lop",
      "completion": {
        "field": "suggest"
      }
    }
  }
}'

echo "⏳ Đợi Dashboards sẵn sàng..."
until curl -s "$DASH_URL/api/status" | grep -q 'green'; do
  sleep 5
done
echo "✅ Dashboards OK"

echo "=== Import Dashboard mẫu ==="
curl -X POST "$DASH_URL/api/saved_objects/_import?overwrite=true" \
  -H 'kbn-xsrf: true' \
  --form file=@/usr/share/opensearch/init-scripts/vietnamese-dashboard.ndjson

echo "🎉 Hoàn tất: Search + Highlight + Suggestions đã sẵn sàng"
