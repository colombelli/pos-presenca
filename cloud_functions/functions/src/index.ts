import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase)


export const presenceRegistration = functions.https.onRequest((request, response) => {
  
    //let regCode = request.query.regCode
    let userID = request.query.userID

    //let codeStr = String(regCode)
    let userIDstr = String(userID)

    admin.firestore().collection("users").doc(userIDstr).get()
        .then(snapshot => {  
            
            const userData = snapshot.data()
            
            if (userData){
                
                const program = String(userData.program)
                admin.firestore().collection("programs").where("name", "==", program).get()
                    .then(progsSnapshot => {
                        
                        if (progsSnapshot.docs){
                            const programID = progsSnapshot.docs[0].id
                            response.send(programID)
                        }

                    })
                    .catch(err => {
                        response.send('Error:'+err)
                    })


            } else {
                response.send("Error: couldn't find user")
            }

        })
        .catch(err => {
            response.send('Error:'+err)
        }) 
});
