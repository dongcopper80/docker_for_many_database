const API_BASE = 'http://localhost:3000';
const searchBox = document.getElementById('searchBox');
const suggestionsList = document.getElementById('suggestions');
const resultsDiv = document.getElementById('results');
const toggleThemeBtn = document.getElementById('toggleTheme');

let typingTimer;
const debounceDelay = 300;

toggleThemeBtn.addEventListener('click', () => {
  document.body.classList.toggle('dark');
  toggleThemeBtn.textContent = document.body.classList.contains('dark')
    ? '☀️ Light Mode'
    : '🌙 Dark Mode';
});

searchBox.addEventListener('input', () => {
  clearTimeout(typingTimer);
  const query = searchBox.value.trim();
  if (!query) {
    suggestionsList.innerHTML = '';
    resultsDiv.innerHTML = '';
    return;
  }
  typingTimer = setTimeout(() => {
    fetchSuggestions(query);
    fetchResults(query);
  }, debounceDelay);
});

function fetchSuggestions(query) {
  fetch(`${API_BASE}/suggest?q=${encodeURIComponent(query)}`)
    .then(res => res.json())
    .then(data => {
      suggestionsList.innerHTML = '';
      (data.suggestions || []).forEach(s => {
        const li = document.createElement('li');
        li.textContent = s.text;
        li.addEventListener('click', () => {
          searchBox.value = s.text;
          suggestionsList.innerHTML = '';
          fetchResults(s.text);
        });
        suggestionsList.appendChild(li);
      });
    })
    .catch(console.error);
}

function fetchResults(query) {
  fetch(`${API_BASE}/search?q=${encodeURIComponent(query)}`)
    .then(res => res.json())
    .then(data => {
      resultsDiv.innerHTML = '';
      (data.hits || []).forEach(hit => {
        const div = document.createElement('div');
        div.className = 'result';
        const title = hit.highlight.title ? hit.highlight.title.join(' ... ') : hit.source.title;
        const content = hit.highlight.content ? hit.highlight.content.join(' ... ') : hit.source.content;
        div.innerHTML = `<h3>${title}</h3><p>${content}</p>`;
        resultsDiv.appendChild(div);
      });
    })
    .catch(console.error);
}