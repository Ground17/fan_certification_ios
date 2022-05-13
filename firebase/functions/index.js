// The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
const functions = require('firebase-functions');

// The Firebase Admin SDK to access Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

// const https = require('https');

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

exports.addHeart = functions.https.onCall(async (data, context) => {
    const platform = data.platform;
    const account = data.account;

    // Checking attribute.
    if (!(typeof platform === 'string') || platform.length === 0) {
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
            'one arguments "platform" containing the message text to add.');
    }
    if (!(typeof account === 'string') || account.length === 0) {
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
            'one arguments "account" containing the message text to add.');
    }

    // Checking that the user is authenticated.
    if (!context.auth) {
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError('failed-precondition', 'The function must be called ' +
            'while authenticated.');
    }

    if (platform == "0") { // YouTube
        // transaction
        const YouTubeRef = admin.firestore().collection('YouTube').doc(account);
        const myRef = admin.firestore().collection('Users').doc(context.auth.uid);
        try {
            return await admin.firestore().runTransaction(async (t) => {
                const YouTubeDoc = await t.get(YouTubeRef);
                const myDoc = await t.get(myRef);

                let celeb = myDoc.data().celeb;
                let hearts = YouTubeDoc.data().count + 1;
                
                for (let i = 0; i < celeb.length; i++) {
                    const now = new Date();
                    if ((celeb[i].recent.seconds + 300) * 1000 < now) {
                        // Note: this could be done without a transaction
                        //       by updating the population using FieldValue.increment()
                        t.update(YouTubeRef, {count: hearts});

                        celeb[i].recent = now;
                        celeb[i].count = celeb[i].count + 1;
                        t.update(myRef, {celeb: celeb});
                        break;
                    } else {
                        throw 'Sorry! Try after 5 minutes.';
                    }
                }
            })
            .then(() => {
                console.log('Transaction success!');
                return {status: 200, message: "success"};
            })
            .catch((e) => {
                console.log('Transaction failure:', e);
                return {status: 400, message: e};
            });
        } catch (e) {
            console.log('Transaction failure:', e);
            return {status: 400, message: e};
        }
    } else { // Instagram
        const InstaRef = admin.firestore().collection('Instagram').doc(account);
        const myRef = admin.firestore().collection('Users').doc(context.auth.uid);
    }

    return {status: 400, message: "Unknown error."};
});

exports.manageFollow = functions.https.onCall(async (data, context) => {
    const method = data.method; // add, delete
    const platform = data.platform;
    const account = data.account;
    const title = data.title;
    const profileURL = data.url;

    // Checking attribute.
    if (!(typeof method === 'string') || method.length === 0) {
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
            'one arguments "method" containing the message text to add.');
    }
    if (!(typeof platform === 'string') || platform.length === 0) {
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
            'one arguments "platform" containing the message text to add.');
    }
    if (!(typeof account === 'string') || account.length === 0) {
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError('invalid-argument', 'The function must be called with ' +
            'one arguments "account" containing the message text to add.');
    }

    // Checking that the user is authenticated.
    if (!context.auth) {
        // Throwing an HttpsError so that the client gets the error details.
        throw new functions.https.HttpsError('failed-precondition', 'The function must be called ' +
            'while authenticated.');
    }

    const celebDoc = await admin.firestore().collection('Users').doc(context.auth.uid).get();
    if (celebDoc.exists) {
        let celeb = celebDoc.data().celeb || [];
        if (method == "add") { // add
            for (let i = 0; i < celeb.length; i++) { // check that celeb already exists.
                if (celeb[i].account == account && celeb[i].platform == platform) {
                    return {status: 400, message: "Already exists."};
                }
            }

            if (celeb.length < 3) {
                // transaction
                const YouTubeRef = admin.firestore().collection('YouTube').doc(account);
                const myRef = admin.firestore().collection('Users').doc(context.auth.uid);
                try {
                    return await admin.firestore().runTransaction(async (t) => {
                        const YouTubeDoc = await t.get(YouTubeRef);
                        const myDoc = await t.get(myRef);

                        const now = new Date();
                        celeb.push({
                            account: account,
                            count: 0,
                            platform: platform,
                            recent: now,
                            since: now,
                            title: title,
                            url: profileURL
                        });

                        if (!YouTubeDoc.exists) {
                            t.set(YouTubeRef, {count: 0, follow: 1});
                        } else {
                            t.update(YouTubeRef, {follow: admin.firestore.FieldValue.increment(1)});
                        }

                        t.update(myRef, {celeb: celeb});
                    })
                    .then(() => {
                        console.log('Transaction success!');
                        return {status: 200, message: "success"};
                    })
                    .catch((e) => {
                        console.log('Transaction failure:', e);
                        return {status: 400, message: e};
                    });
                } catch (e) {
                    return {status: 400, message: e};
                }
            } else {
                return {status: 400, message: "Add limit: 3"}
            }
        } else if (method == "update") { // update
            for (let i = 0; i < celeb.length; i++) {
                if (celeb[i].account == account && celeb[i].platform == platform) {
                    celeb[i].title = title;
                    celeb[i].url = profileURL;
                    return await admin.firestore().collection('Users').doc(context.auth.uid).update({celeb: celeb})
                    .then(() => {
                        return {status: 200, message: "success"};
                    })
                    .catch((e) => {
                        return {status: 400, message: e};
                    });
                }
            }
        } else if (method == "delete") { // delete
            // transaction
            const YouTubeRef = admin.firestore().collection('YouTube').doc(account);
            const myRef = admin.firestore().collection('Users').doc(context.auth.uid);
            try {
                return await admin.firestore().runTransaction(async (t) => {
                    const YouTubeDoc = await t.get(YouTubeRef);
                    const myDoc = await t.get(myRef);

                    for (let i = 0; i < celeb.length; i++) {
                        if (celeb[i].account == account && celeb[i].platform == platform) {
                            t.update(YouTubeRef, {count: YouTubeDoc.data().count - celeb[i].count, follow: YouTubeDoc.data().follow - 1});

                            celeb = celeb.filter(el => (el.account != account && el.platform != platform));
                            t.update(myRef, {celeb: celeb});
                            break;
                        }
                    }
                })
                .then(() => {
                    console.log('Transaction success!');
                    return {status: 200, message: "success"};
                })
                .catch((e) => {
                    console.log('Transaction failure:', e);
                    return {status: 400, message: e};
                });
            } catch (e) {
                console.log('Transaction failure:', e);
                return {status: 400, message: e};
            }
        }
    } else {
        return {status: 400, message: "Your data doesn't exist."}
    }

    return {status: 400, message: "Unknown error"}
});