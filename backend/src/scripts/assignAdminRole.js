const { auth } = require('./utils/firebase');

// Assign admin role to a user
const assignAdminRole = async (uid) => {
    try {
        await auth.setCustomUserClaims(uid, { admin: true });
        console.log(`Admin role assigned to user with UID: ${uid}`);
    } catch (error) {
        console.error('Error assigning admin role:', error.message);
    }
};

// Replace 'user-uid' with the actual UID of the user
assignAdminRole('user-uid');
