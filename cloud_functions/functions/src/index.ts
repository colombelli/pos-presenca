import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp(functions.config().firebase)


export const presenceRegistration = functions.https.onRequest((request, response) => {
  
    let regCode = request.query.regCode
    let userID = request.query.userID

    var codeStr = String(regCode)
    var userIDstr = String(userID)


    function validateStudentPresence(progId: string){

        admin.firestore().collection("programs").doc(progId).get()
            .then(snapshot => {
                const programInfo = snapshot.data()

                if (programInfo){
                    
                    if (codeStr == programInfo.key || codeStr == programInfo.key2){
                        response.send(true)
                    } else {
                        response.send(false)
                    }
                }

                else {
                    throw new Error("Couldn't find student's prorgam");
                }

            })
            .catch(e => {
                throw new Error(e);
            })
    }


    admin.firestore().collection("users").doc(userIDstr).get()
        .then(snapshot => {  
            
            const userData = snapshot.data()
            
            if (userData){
                
                const program = String(userData.program)
                admin.firestore().collection("programs").where("name", "==", program).get()
                    .then(progsSnapshot => {
                        
                        if (progsSnapshot.docs){
                            const programID = progsSnapshot.docs[0].id
                            validateStudentPresence(programID)   
                        }
                        else{
                            throw new Error("Couldn't find student's prorgam");                            
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
