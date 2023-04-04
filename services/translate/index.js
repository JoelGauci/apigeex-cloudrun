const express = require('express');
const app = express();

app.get('/translate', (req, res) => {
  const name = process.env.NAME || 'Translate';
  res.json({
    service: "translate",
    id: "789-ghi"
  });
});

const port = parseInt(process.env.PORT) || 8080;
app.listen(port, () => {
  console.log(`Translate service: listening on port ${port}`);
});
