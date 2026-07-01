const express = require('express');
const router = express.Router();
const {protect} = require("../middleware/authMiddleware");

const {sendMessage, getMessages,markMessagesAsSeen} = require("../controllers/messageController");

router.post("/", protect, sendMessage);
router.get("/:userId", protect, getMessages);
router.put("/seen/:userId", protect, markMessagesAsSeen);
console.log("Message routes loaded");

module.exports =router;