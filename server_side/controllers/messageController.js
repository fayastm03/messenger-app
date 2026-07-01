const Message = require('../models/Message');
const { getIO, getOnlineUsers } = require("../socket");

const sendMessage = async (req, res) => {
    try{
        const { receiverId, text } = req.body;
        if(!receiverId || !text){
            return res.status(400).json({ success: false, message: "Reciever ID and content are required" });
        }

        const message= await Message.create({
            sender: req.user._id,
            receiverId: receiverId,
            text,
        });

        const io = getIO();
        const onlineUsers = getOnlineUsers();

        const payload = {
          _id : message._id,
          text : message.text,
          sender : req.user._id,
          receiverId : receiverId,
          createdAt : message.createdAt,
          seen: message.seen
        }

        const receiverSocketId = onlineUsers[receiverId];

        if(receiverSocketId){
          io.to(receiverSocketId).emit("receiveMessage",payload);
          io.to(receiverSocketId).emit("contactUpdated");
        };

        const senderSocketId = onlineUsers[req.user._id.toString()];

        if(senderSocketId){
          io.to(senderSocketId).emit("contactUpdated");
        }

        res.status(201).json({
            success:true,
            message
        });

    }catch (e) {
  console.log(e);

  res.status(500).json({
    success: false,
    message: e.message,
  });
};
};

const getMessages = async (req, res) => {
  try {
    const { userId } = req.params;

    const messages = await Message.find({
      $or: [
        { sender: req.user._id, receiverId: userId },
        { sender: userId, receiverId: req.user._id },
      ],
    }).sort({ createdAt: 1 });

    res.json(messages);
  } catch (e) {
  console.log(e);

  res.status(500).json({
    success: false,
    message: e.message,
  });
}
};

const markMessagesAsSeen = async (req, res) => {
  try{
    const {userId } = req.params;
    await Message.updateMany(
      {
        sender: userId,
        receiverId: req.user._id,
        seen: false
      },
      {
        seen: true,
      }
    );
    res.json({
      success: true,
      message: "Messages marked as seen"
    });

  }catch(e){
    console.log(e);
     res.status(500).json({
      success: false,
      message: e.message,
    });
  }
};

module.exports = {
    sendMessage,
    getMessages,
    markMessagesAsSeen,
};