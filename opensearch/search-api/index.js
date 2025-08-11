const express = require('express');
const { Client } = require('@opensearch-project/opensearch');
const cors = require('cors');
const helmet = require('helmet');

const PORT = process.env.PORT || 3000;
const OS_NODE = process.env.OS_NODE || 'https://opensearch-node1:9200';
const OS_USER = process.env.OS_USER || 'admin';
const OS_PASS = process.env.OS_PASS || 'admin';

const app = express();
app.use(express.json());
app.use(cors());
app.use(helmet());

// Opensearch client - ignore self-signed certs in local dev
const client = new Client({
  node: OS_NODE,
  auth: {
    username: OS_USER,
    password: OS_PASS
  },
  tls: {
    rejectUnauthorized: false
  }
});

// health
app.get('/health', async (req, res) => {
  try {
    const { body } = await client.cluster.health();
    res.json(body);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// search with highlight
// GET /search?q=lop+xe&size=10
app.get('/search', async (req, res) => {
  const q = req.query.q || '';
  const size = parseInt(req.query.size || '10', 10);

  try {
    const body = await client.search({
      index: 'blog_vi',
      size,
      body: {
        query: {
          multi_match: {
            query: q,
            fields: ['title^2', 'content'],
            fuzziness: 'AUTO'
          }
        },
        highlight: {
          pre_tags: ['<mark>'],
          post_tags: ['</mark>'],
          fields: {
            title: {},
            content: {}
          }
        }
      }
    });

    // normalize results
    const hits = (body.body.hits.hits || []).map(h => ({
      id: h._id,
      score: h._score,
      source: h._source,
      highlight: h.highlight || {}
    }));

    res.json({ took: body.body.took, total: body.body.hits.total, hits });
  } catch (err) {
    console.error('search error', err);
    res.status(500).json({ error: err.message });
  }
});

// suggest endpoint using completion suggester
// GET /suggest?q=lop&size=5
app.get('/suggest', async (req, res) => {
  const q = req.query.q || '';
  const size = parseInt(req.query.size || '5', 10);

  try {
    const body = await client.search({
      index: 'blog_vi',
      size: 0,
      body: {
        suggest: {
          'blog-suggest': {
            prefix: q,
            completion: {
              field: 'suggest',
              size
            }
          }
        }
      }
    });

    const suggestions = (body.body.suggest && body.body.suggest['blog-suggest']) ?
      body.body.suggest['blog-suggest'][0].options.map(o => ({ text: o.text, score: o._score })) : [];

    res.json({ suggestions });
  } catch (err) {
    console.error('suggest error', err);
    res.status(500).json({ error: err.message });
  }
});

// optional: endpoint to create sample docs (idempotent)
app.post('/reindex-sample', async (req, res) => {
  try {
    // simple upsert: delete index then recreate mapping + docs (safe for demo)
    await client.indices.delete({ index: 'blog_vi' }).catch(()=>{});
    await client.indices.create({
      index: 'blog_vi',
      body: {
        settings: {
          analysis: {
            analyzer: {
              vi_analyzer: {
                type: 'custom',
                tokenizer: 'standard',
                filter: ['lowercase','stop','asciifolding']
              }
            }
          }
        },
        mappings: {
          properties: {
            title: { type: 'text', analyzer: 'vi_analyzer' },
            content: { type: 'text', analyzer: 'vi_analyzer' },
            suggest: { type: 'completion', analyzer: 'vi_analyzer' }
          }
        }
      }
    });

    // insert docs
    const docs = [
      {
        title: 'Kinh nghiệm lái xe đường dài',
        content: 'Lái xe đường dài cần chuẩn bị sức khỏe, kiểm tra lốp xe và mang theo đồ dự phòng.',
        suggest: ['lái xe', 'kinh nghiệm lái xe']
      },
      {
        title: 'Bảo dưỡng xe ô tô mùa mưa',
        content: 'Kiểm tra phanh, gạt mưa và hệ thống đèn để đảm bảo an toàn.',
        suggest: ['bảo dưỡng xe', 'bảo dưỡng ô tô']
      },
      {
        title: 'Chọn lốp xe phù hợp',
        content: 'Lốp xe phù hợp giúp tiết kiệm nhiên liệu và tăng độ bám đường.',
        suggest: ['lốp xe', 'chọn lốp xe']
      }
    ];

    for (const doc of docs) {
      await client.index({ index: 'blog_vi', body: doc });
    }
    await client.indices.refresh({ index: 'blog_vi' });

    res.json({ ok: true });
  } catch (err) {
    console.error('reindex error', err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Search API listening on port ${PORT}`);
});
