const express = require("express");
const app = express();
const port = 3000;

app.get("/redirect", (req, res) => {
  const origin = req.query.origin;
  const accessToken = req.headers["x-auth-request-access-token"];
  if (origin && accessToken) {
    res.redirect(`${origin}?token=${accessToken}`);
  } else if (origin) {
    res.redirect(origin);
  } else {
    res.send("No origin specified in the query parameters.");
  }
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
