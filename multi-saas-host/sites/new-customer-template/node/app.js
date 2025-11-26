const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end('Hello World from Node!\n');
});

server.listen(port, () => {
  console.log(`Hello-world server listening on :${port}`);
});
