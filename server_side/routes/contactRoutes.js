
const express = require("express");
const router = express.Router();

const {protect} = require("../middleware/authMiddleware");
const {getContacts, addContact,getUsers} = require("../controllers/contactController");

router.post("/add", protect, addContact);
router.get("/", protect, getContacts);
router.get("/users", protect, getUsers);

module.exports = router;