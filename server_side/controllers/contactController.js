const User = require("../models/User");
const Message = require("../models/Message");


const getUsers = async (req, res) => {
  try {
    const users = await User.find({
      _id: { $ne: req.user._id }, 
    }).select("-password"); 

    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const addContact = async (req, res) => {
  try {
    const currentUserId = req.user._id;
    const { email } = req.body;

    const contactUser = await User.findOne({ email });

    if (!contactUser) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (contactUser._id.toString() === currentUserId.toString()) {
      return res.status(400).json({
        success: false,
        message: "You cannot add yourself",
      });
    }

    const user = await User.findById(currentUserId);

    if (user.contacts.includes(contactUser._id)) {
      return res.status(400).json({
        success: false,
        message: "Already in contacts",
      });
    }

    user.contacts.push(contactUser._id);
    await user.save();

    res.json({
      success: true,
      message: "Contact added successfully",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server error",
    });
  }
};

const getContacts = async (req, res) => {

  try {

    const user = await User.findById(req.user._id)
      .populate("contacts", "name email status");

    const contactsWithLastMessage = await Promise.all(

      user.contacts.map(async (contact) => {

        const lastMessage = await Message.findOne({
          $or: [
            {
              sender: req.user._id,
              receiverId: contact._id,
            },
            {
              sender: contact._id,
              receiverId: req.user._id,
            },
          ],
        }).sort({ createdAt: -1 });

        return {
          _id: contact._id,
          name: contact.name,
          email: contact.email,
          status: contact.status,

          lastMessage: lastMessage?.text || "",

          lastMessageTime:
              lastMessage?.createdAt || null,
        };
      }),
    );

    contactsWithLastMessage.sort((a, b) => {

      if (!a.lastMessageTime) return 1;
      if (!b.lastMessageTime) return -1;

      return new Date(b.lastMessageTime)
        - new Date(a.lastMessageTime);
    });

    res.json(contactsWithLastMessage);

  } catch (error) {

    console.log(error);

    res.status(500).json({
      message: error.message,
    });
  }
};


module.exports = {
  getUsers,
  addContact,
  getContacts,
};