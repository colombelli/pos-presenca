import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase)


export const presenceRegistration = functions.https.onRequest((request, response) => {
  
    let regCode = request.query.regCode
    let userID = request.query.userID

    let codeStr = String(regCode)
    let userIDstr = String(userID)

    admin.firestore().collection("users").doc(userIDstr).get()
        .then(snapshot => {  
            
            let userData = snapshot.data()
            
            if (userData){
                response.send(userData)
            } else {
                response.send("Error: couldn't find user")
            }
            console.log(codeStr)
            console.log(userData)

            

        })
        .catch(err => {
            response.send('Error:'+err)
        }) 
});
