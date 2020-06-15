import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase)


export const presenceRegistration = functions.https.onRequest((request, response) => {
  
    let regCode = request.query.redCode
    let userID = request.query.userID

    let codeStr = String(regCode)
    let userIDstr = String(userID)

    admin.firestore().collection("users").doc(userIDstr).get()
        .then(snapshot => {  
            
            let userData = snapshot.data()
            response.send(userData)
            response.send("AND"+codeStr)
            

        })
        .catch(err => {
            response.send('Error:'+err)
        }) 



  
    response.send("");
});
