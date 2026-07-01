const express = require("express");
const dotenv = require("dotenv");
const cors = require("cors");
const http = require("http");
const { initSocket } = require("./socket");

dotenv.config();

const app = express();
const server = http.createServer(app);
initSocket(server);

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("API is running...");
});

const PORT = process.env.PORT || 3000;
const connectDB = require("./config/db");
connectDB();



const authRoutes = require("./routes/authRoutes");
app.use("/api/auth", authRoutes);

const contactRoutes = require("./routes/contactRoutes");
app.use("/api/contacts", contactRoutes);

const messageRoutes = require("./routes/messageRoutes");
app.use("/api/messages", messageRoutes);


server.listen(PORT, "0.0.0.0",() => {
  console.log(`Server running on port ${PORT}`);
});
