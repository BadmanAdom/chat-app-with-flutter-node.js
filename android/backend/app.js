const express = require("express");
const cors = require("cors");
const app = express();
const port = 4000 || process.env.PORT;

app.use(cors());

const server = app.listen(port, () => {
  console.log(`Server is running on port ${4000}`);
});

const io = require("socket.io")(server);

const connectedUser = new Set();
io.on("connection", (socket) => {
  console.log("Connection is successful", socket.id);
  io.emit("connected-user", connectedUser.size);
  connectedUser.add(socket.id);
  socket.on("disconnect", () => {
    console.log("Disconnected", socket.id);
    connectedUser.delete(socket.id);
    io.emit("connected-user", connectedUser.size);
  });
  socket.on("message", (data) => {
    console.log(data);
    socket.broadcast.emit("message-receive", data);
  });
});
