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
exports.sendNotification2 = functions.firestore
  .document("sessions/{sessionID}")
  .onUpdate((change, context) => {
    // Get an object representing the document
    // e.g. {'name': 'Marie', 'age': 66}
    const newValue = change.after.data();

    // access a particular field as you would any JS property
    const to = newValue.FROM;
    const to_name = newValue.FROM_NAME;
    const from = newValue.TO;
    const from_name = newValue.TO_NAME;
    const image_name = newValue.IMAGE_NAME;
    const guess = newValue.GUESS;
    const answer = newValue.ANSWER;

    var payload = {
      data: {
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        from_name: from_name,
        image_name: image_name,
        type: "reply"
      }
    };

    var options = {
      priority: "high",
      ttl: 60 * 60 * 24
    };

    if (answer == 0) {
      payload.notification = {
        title: "Cloodle Answer!",
        body: `${from_name} replied to a cloodle you sent. Check it out! ${guess}`
      };

      return admin.messaging().sendToDevice(to, payload, options);
    } else {
      payload.notification = {
        title: "Cloodle Reply!",
        body: `${to_name} said you got it ${answer == 1 ? "right" : "wrong"}.`
      };

      return admin.messaging().sendToDevice(from, payload, options);
    }
  });

exports.sendNotification = functions.https.onRequest((req, res) => {
  const to = req.query.to;
  // const fromId = req.query.fromId;
  const fromPushId = req.query.fromPushId;
  const fromName = req.query.fromName;
  const imageName = req.query.imageName;
  // const type = req.query.type;

  var payload = {
    data: {
      click_action: "FLUTTER_NOTIFICATION_CLICK",
      fromPushId: fromPushId,
      fromName: fromName,
      imageName: imageName,
      type: "challenge"
    }
  };

  payload.notification = {
    title: "New Cloodle!",
    body: `${fromName} sent you a cloodle. Check it out!`
  };

  var options = {
    priority: "high",
    ttl: 60 * 60 * 24
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
