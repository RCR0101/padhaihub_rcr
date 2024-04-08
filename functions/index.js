const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendPushNotification = functions.firestore
    .document('chats/{chatId}/messages/{messageId}')
    .onCreate(async (snap, context) => {
        const message = snap.data();

        // Assuming the recipient's user ID is stored in the message.
        // This needs to be adjusted based on your actual data structure.
        const recipientId = message.recipientId; 

        // Fetch the recipient's FCM token from Firestore
        const userRef = admin.firestore().collection('users').doc(recipientId);
        const doc = await userRef.get();
        if (!doc.exists) {
            console.log('No such user!');
            return;
        }
        const recipientFcmToken = doc.data().fcmToken;
        if (!recipientFcmToken) {
            console.log('No FCM Token found for recipient:', recipientId);
            return;
        }

        const payload = {
            notification: {
                title: `New message!`, // Customize this title
                body: message.text, // And customize this message body
                // You can add more notification options as needed
            },
            data: {
                // This is where you can add any data you want to send along with the notification
                chatId: context.params.chatId, // For example, sending the chatId in the notification data
            },
            token: recipientFcmToken, // Specify the token here
        };
        try {
            const response = await admin.messaging().send(payload);
            console.log('Successfully sent message:', response);
        } catch (error) {
            console.log('Error sending message:', error);
        }
    });