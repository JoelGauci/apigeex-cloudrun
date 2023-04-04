const express = require('express');
const app = express();

app.get('/search', (req, res) => {
  const name = process.env.NAME || 'Search';
  res.json({
    service: "search",
    id: "456-def"
  });
});

const port = parseInt(process.env.PORT) || 8080;
app.listen(port, () => {
  console.log(`Search service: listening on port ${port}`);
});
