const functions = require("firebase-functions");

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require("firebase-admin");
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   response.send("Hello from Firebase!");
// });

exports.sendNotification = functions.https.onRequest((req, res) => {
  const to = req.query.to;
  // const fromId = req.query.fromId;
  // const fromPushId = req.query.fromPushId;
  // const fromName = req.query.fromName;
  // const type = req.query.type;

  var payload = {
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK"
      // fromId: fromId,
      // fromPushId: fromPushId,
      // fromName: fromName,
      // type: type
    }
  };

  payload.notification = {
    title: "Welcome to Cloodle!",
    body: `Hi der! Hope you enjoy looking at clouds!`
  };

  var options = {
    priority: "high",
    timeToLive: 60 * 60 * 24
  };

  admin
    .messaging()
    .sendToDevice(to, payload, options)
    .then(function(response) {
      res.send(200, "ok");
    })
    .catch(function(error) {
      res.send(200, "failed");
    });
});
