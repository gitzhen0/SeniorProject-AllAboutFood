var rhit = rhit || {};
var current = "";

rhit.main = function () {
	firebase.auth().onAuthStateChanged((user) => {
		if (user) {
			current = user;
		} else {
		}
	});


	rhit.startFirebaseUI();
};

rhit.startFirebaseUI = function () {
	var uiConfig = {
		// signInSuccessUrl: redirect + "#access_token=" + current,
		signInOptions: [
			// Leave the lines as is for the providers you want to offer your users.
			firebase.auth.EmailAuthProvider.PROVIDER_ID
		],
		callbacks: {
			signInSuccess: function(currentUser, credential, redirectUrl) {
				// Manually redirect.
				const params = new URLSearchParams(location.search);
				if (params.get("client_id") != "IVFCRSkillAuth") {
					console.log("Invalid ID")
					return false;
				}
				redirect = params.get("redirect_uri");
				state = params.get("state");
				redirect += "#access_token=" + currentUser.uid + "&token_type=Bearer&state=" + state;
				window.location.assign(redirect);
				// Do not automatically redirect.
				return false;
			},
		}
	};
	const ui = new firebaseui.auth.AuthUI(firebase.auth());
	ui.start('#firebaseui-auth-container', uiConfig);
	firebase.auth().setPersistence(firebase.auth.Auth.Persistence.NONE)
  	.then(() => {
    	return firebase.auth().signInWithEmailAndPassword(email, password);
  	})
  	.catch((error) => {
    // Handle Errors here.
    	var errorCode = error.code;
    	var errorMessage = error.message;
  	});
}

rhit.main();