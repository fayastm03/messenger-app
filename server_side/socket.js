const { Server } = require("socket.io");

let io;

const onlineUsers = {};
const socketToUserId = {};

const initSocket = (server) => {

  io = new Server(server, {
    cors: {
      origin: "*",
    },
  });

  io.on("connection", (socket) => {

    console.log("User connected:", socket.id);

    socket.on("registerUser", (userId) => {

      console.log(
    "REGISTER USER:",
    userId
  );

      onlineUsers[userId] = socket.id;

      socketToUserId[socket.id] = userId;

      console.log("Online Users:", onlineUsers);

      io.emit(
        "onlineUsers",
        Object.keys(onlineUsers),
      );
    });

    socket.on("disconnect", () => {

      const userId =
          socketToUserId[socket.id];

      if (userId) {

        delete onlineUsers[userId];

        delete socketToUserId[socket.id];

        console.log(
          "User disconnected:",
          userId,
        );

        io.emit(
          "onlineUsers",
          Object.keys(onlineUsers),
        );

      }
    });
  });
};

const getIO = () => io;

const getOnlineUsers = () => onlineUsers;

module.exports = {
  initSocket,
  getIO,
  getOnlineUsers,
};