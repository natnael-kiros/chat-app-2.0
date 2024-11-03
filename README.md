# Chat App 2.0

## Description

The Chat App 2.0 is a mobile application built using **Flutter** that allows users to engage in real-time messaging. Users can sign up with their name, phone number, and profile picture, creating a personalized experience. The app utilizes a separate Dart server to handle requests, authentication, and real-time chatting while storing all messages in a SQLite database.

### Key Features

- **User Registration and Authentication**: Users can sign up with their name, phone number, and a profile picture. Secure login ensures user data is protected.
- **Contact Management**: 
  - Add contacts either manually by entering their phone number or by importing from the device's contact list.
  - Start chatting with added contacts instantly.
- **Group Chat Functionality**: Create group chats and invite contacts to join, enabling collaborative conversations.
- **Broadcast Messages**: Similar to Telegram, users can send broadcast messages to update others with important information.
- **Chat List**: All chats are organized in a list based on timestamps, allowing users to easily find and continue conversations.
- **Message Reactions**: Users can react to messages with emojis, enhancing interactions in chats.
- **Media Sharing**: Users can send images, videos, and audio messages within chats, making conversations more engaging.
- **Typing Indicators**: Users can see when their contacts are typing, providing a real-time chatting experience.
- **Push Notifications**: Users receive notifications for new messages and activity, ensuring they stay updated.

## Architecture

- **Client**: Built with Flutter, providing a smooth and responsive user interface for real-time communication.
- **Server**: A Dart server that manages user requests, authentication, and real-time messaging.
- **Database**: SQLite is used for local storage of messages, ensuring data persistence and efficient retrieval.

## Screenshots

Include screenshots of your application to showcase its UI and functionality.

<table>
  <tr>
    <td><img src="screenshots/signup.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/login.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/chat.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/group.jpg" width="200" style="margin-bottom: 20px;"/></td>
  </tr>
  <tr>
    <td>Sign Up</td>
    <td>Login</td>
    <td>Chat</td>
    <td>Group</td>
  </tr>
</table>

<table>
  <tr>
    <td><img src="screenshots/contacts.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/groupmessage.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/groupname.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/groupselect.jpg" width="200" style="margin-bottom: 20px;"/></td>
  </tr>
  <tr>
    <td>Contacts</td>
    <td>Group Message</td>
    <td>Group Name</td>
    <td>Group Select</td>
  </tr>
</table>

<table>
  <tr>
    <td><img src="screenshots/message.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/message2.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/addcontact.jpg" width="200" style="margin-bottom: 20px;"/></td>
    <td><img src="screenshots/drawer.jpg" width="200" style="margin-bottom: 20px;"/></td>
  </tr>
  <tr>
    <td>Message</td>
    <td>Message 2</td>
    <td>Add Contact</td>
    <td>Drawer</td>
  </tr>
</table>

## Installation

### Prerequisites

Before starting, make sure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
- A Dart environment set up for the server.

### Steps

1. **Clone the repository**:

   ```bash
   git clone https://github.com/username/chat_app_2.0.git
