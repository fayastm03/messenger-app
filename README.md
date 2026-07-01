# 📱 Flutter Chat Application

A real-time chat application built using **Flutter**, **Node.js**, and **MongoDB** that allows users to communicate seamlessly with secure authentication and real-time messaging.

---

## 🚀 Features

* User Registration & Login
* JWT Authentication
* Add Contacts
* Real-Time Messaging
* Online / Offline Status
* Chat History Storage
* State Management using Provider
* REST API Integration using Dio
* Image Sharing *(In Progress)*

---

## 🛠 Tech Stack

### Frontend

* Flutter
* Dart
* Provider
* Dio
* Flutter Secure Storage

### Backend

* Node.js
* Express
* Socket.IO
* JWT Authentication

### Database

* MongoDB

---

## 📂 Project Structure

```bash
chat-application/
│
├── frontend/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── providers/
│   │   ├── services/
│   │   ├── widgets/
│   │   └── main.dart
│   │
│   └── pubspec.yaml
│
├── backend/
│   ├── models/
│   ├── routes/
│   ├── controllers/
│   ├── middleware/
│   ├── server.js
│   └── package.json
│
└── README.md
```

---

## ⚙️ System Architecture

```text
Flutter App
   ↕
 REST APIs (Dio)
   ↕
Node.js + Express
   ↕
 MongoDB

Real-Time Communication:
Flutter ↔ Socket.IO ↔ Backend
```

---

## 🔐 Authentication Flow

1. User registers with name, email, and password
2. Password is encrypted and stored securely
3. User logs in
4. Backend generates JWT token
5. Token stored using Flutter Secure Storage
6. Protected routes require token verification

---

## 📡 API Endpoints

### Authentication

```bash
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/profile
```

### Users

```bash
GET /api/users
GET /api/users/:id
```

### Contacts

```bash
POST /api/contacts
GET  /api/contacts
```

### Messages

```bash
POST /api/messages
GET  /api/messages/:userId
```

---

## 💬 Messaging Flow

* User selects a contact
* Chat screen loads previous messages
* Messages are fetched from MongoDB
* New messages are sent via API/Socket
* Receiver gets messages in real time

---

## 📱 Screens

* Login Screen
* Register Screen
* Home Screen
* Contacts Screen
* Chat Screen

---

## 🔧 Installation

### Clone Repository

```bash
git clone https://github.com/fayastm03/messenger-app.git
cd chat-application
```

### Backend Setup

```bash
cd backend
npm install
```

Create `.env` file:

```env
PORT=3000
MONGO_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key
```

Run backend:

```bash
npm run dev
```

### Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

---

## 📌 Future Improvements

* Image Sharing
* Voice Messages
* Group Chat
* Video Calls
* Push Notifications
* End-to-End Encryption

---

## 👨‍💻 Author

**Fayas T M**
Flutter Developer | Software Developer

GitHub: [fayastm03](https://github.com/fayastm03?utm_source=chatgpt.com)
LinkedIn: [Fayas T M](https://www.linkedin.com/in/fayas-tm-098467322?utm_source=chatgpt.com)

---

## ⭐ Support

If you like this project, please give it a star ⭐
