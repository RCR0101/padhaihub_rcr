# PadhaiHub

PadhaiHub is an application designed specifically for campus students, facilitating seamless chat and note-sharing as PDFs among peers.

## Project Plan

The development plan is structured into three major phases:

1. [Understanding the Project](#understanding-the-project)
2. [Tech Stack](#tech-stack)
3. [Approach](#approach)

### Understanding the Project

**Title**: PadhaiHub

**Salient Features**:
- **Authentication**: Secure access via Google OAuth, exclusive to BPHC students.
- **Overview Page**: Quick insights into unread messages, newly shared notes, and pending requests.
- **Student Search**: Find new study partners within your campus.
- **Chatting Features**: Share text messages and PDFs. Edit notes directly in the chat.
- **Broadcast Notes**: Send Notes on Public Channels.
- **Notifications**: Stay updated with push notifications for new notes and messages.
- **Pinned Chats**: Pin up to three chats for quick access.
- **FAQ Section**: Quick answers to common queries.

### Tech Stack

1. **Frontend Development**
   - **Mobile Application Framework**: Flutter (Dart Language)
   - **State Management**: BLoC
2. **Backend Development**
   - **Framework/Language**: (To be decided)
3. **Database**
   - **Storage**: Firebase Firestore (NoSQL)
4. **Authentication**
   - **Method**: Google OAuth2.0
5. **Cloud Services and Hosting**
   - **Infrastructure**: IaaS/PaaS (Specific service to be decided)
   - **File Storage**: (Specific service to be decided)
6. **Development Tools**
   - **Version Control**: Git - GitHub
7. **Monitoring and Analytics**
   - **Performance Monitoring**: (Tool to be decided)
   - **Analytics**: (Tool to be decided)
8. **Testing**
   - **Unit Testing**: Dart
   - **Integration & End-to-End Testing**: Postman API, Flutter Integration Testing

### Approach

- OAuth2.0 using Firebase & Google Cloud Console
  - API used - Google People API & BigQuery API
  - Condition - Logged in Email should have the BPHC domain to allow access.
- Firebase Firestore for Data Storage
  - Stores User Data (entered in Profile Page)
   
---

For any questions or discussions, feel free to open an issue or contact the project maintainers directly.
