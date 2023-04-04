const express = require('express');
const app = express();

app.get('/login', (req, res) => {
  const name = process.env.NAME || 'Login';
  res.json({
    service: "login",
    id: "123-abc"
  });
});

const port = parseInt(process.env.PORT) || 8080;
app.listen(port, () => {
  console.log(`Login service: listening on port ${port}`);
});
