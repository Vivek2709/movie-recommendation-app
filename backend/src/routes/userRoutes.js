const express =  require('express')
const {body,validationResult} = require('express-validator')
const {db} = require('../utils/firebase')
const {auth} = require('../utils/firebase')
const { authenticate, checkAdmin } = require('../middlewares/authMiddleware')
const axios = require('axios')
const { merge } = require('./movieRoutes')

const router = express.Router()

//* Signup
router.post('/auth/signup', authenticate, async (req, res) => {
    try {
        console.log("Decoded User from Token:", req.user); // Debugging
        if (!req.user || !req.user.uid) {
            return res.status(400).json({ message: "Invalid or missing user ID from token." });
        }

        const userId = req.user.uid;  // This should not be undefined now
        const { email, displayName, preferences } = req.body;

        console.log("Received Signup Data:", req.body); // Debugging

        await db.collection('users').doc(userId).set({
            email,
            displayName,
            preferences,
            createdAt: new Date(),
        });

        res.status(201).json({ message: 'User signed up successfully' });
    } catch (error) {
        console.error('Error signing up user:', error.message);
        res.status(500).json({ message: 'Error signing up user', error: error.message });
    }
});


// router.post(
//     '/auth/signup',
//     [
//         // Validation checks
//         body('email').isEmail().withMessage('Valid email is required'),
//         body('displayName').notEmpty().withMessage('Display name is required'),
//         body('preferences.genre')
//             .isArray({ min: 1 })
//             .withMessage('At least one genre is required')
//             .custom((genres) => {
//                 if (genres.some((genre) => typeof genre !== 'string')) {
//                     throw new Error('Genres must be an array of strings');
//                 }
//                 return true;
//             }),
//         body('preferences.theme')
//             .isArray({ min: 1 })
//             .withMessage('At least one theme is required')
//             .custom((themes) => {
//                 if (themes.some((theme) => typeof theme !== 'string')) {
//                     throw new Error('Themes must be an array of strings');
//                 }
//                 return true;
//             }),
//     ],
//     async (req, res) => {
//         // Handle validation errors
//         const errors = validationResult(req);
//         if (!errors.isEmpty()) {
//             return res.status(400).json({ errors: errors.array() });
//         }

//         try {
//             const { email, displayName, preferences, userId } = req.body; // userId is passed from frontend after signup

//             // Save user data to Firestore
//             await db.collection('users').doc(userId).set({
//                 email,
//                 displayName,
//                 preferences, // Example: { genre: ["Action", "Comedy"], theme: ["Dark", "Suspense"] }
//                 createdAt: new Date(),
//             });

//             res.status(201).json({ message: 'User signed up successfully' });
//         } catch (error) {
//             console.error('Error signing up user:', error.message);
//             res.status(500).json({ message: 'Error signing up user', error: error.message });
//         }
//     }
// );

//TODO: Update after client side login is done
//* Login
    
router.post('/auth/login', async (req, res) => {
    try {
        const { email, password, fcmToken } = req.body;
        // Check if email and password are provided
        if (!email || !password) {
            return res.status(400).json({ message: 'Email and password are required' });
        }
        // Retrieve user record
        const userRecord = await auth.getUserByEmail(email).catch(() => null);
        if (!userRecord) {
            return res.status(404).json({ message: 'User not found' });
        }
        // Create a custom token
        const customToken = await auth.createCustomToken(userRecord.uid);
        // Optionally update FCM token in Firestore
        if (fcmToken) {
            const userRef = db.collection('users').doc(userRecord.uid);
            await userRef.set({ fcmToken }, { merge: true });
        }
        res.status(200).json({
            message: 'Login successful',
            customToken, // Send the custom token to the client
        });
    } catch (error) {
        console.error('Error logging in user:', error.message);
        res.status(500).json({ message: 'Error logging in user', error: error.message });
    }
});


//* Mainly Log out is used for client side but this route can work as acknowledgement
router.post('/auth/logout', authenticate, async (req, res) => {
    try {
        // Logout is handled client-side, but this route can be used for cleanup or acknowledgment
        res.json({ message: 'User logged out successfully. Token should be cleared client-side.' });
    } catch (error) {
        console.error('Error during logout:', error.message);
        res.status(500).json({ message: 'Error during logout', error: error.message });
    }
}),


//* Fetch User Profile
router.get('/user/profile', authenticate, async(req,res) => {
    try{
        const userId = req.user.uid;
        const userDoc = await db.collection('users').doc(userId).get();
        if(!userDoc.exists){
            return res.status(404).json({
                message: 'User not found'
            })
        }
        res.json({message: 'User profile fetched', data: userDoc.data()})
    }catch(error){
        console.error('Error fetching user Profile', error.message)
        res.status(500).json({message:'Error fetching user profile', error: error.message})
    }
}),

//* Test USer Auth
router.get('/test-auth', authenticate, (req, res) => {
    res.status(200).json({ message: 'Authentication successful', user: req.user });
});

//* Update User Profile

router.put('/user/profile', authenticate, async(req,res) => {
    try {
        const userId = req.user.uid
        const updates = req.body;
        await db.collection('users').doc(userId).update(updates)
        res.json({message: 'User profile updated successfully'})
    } catch (error) {
        console.error('Error updating user profile', error.message)
        res.status(500).json({message: 'Error Updating user profile', error: error.message})
    }
}),


//* Delete any User Admin Only
router.delete('/admin/delete-user/:uid', authenticate, checkAdmin, async (req, res) => {
    try {
        const { uid } = req.params;
        await auth.deleteUser(uid);
        await db.collection('users').doc(uid).delete();
        res.json({ message: `User with UID: ${uid} deleted successfully` });
    } catch (error) {
        console.error('Error deleting user:', error.message);
        res.status(500).json({ message: 'Error deleting user', error: error.message });
    }
}),

//* Delete self
router.delete('auth/user/delete', authenticate, async (req, res) => {
    try {
        const userId = req.user.uid;
        await auth.deleteUser(userId);
        await db.collection('users').doc(userId).delete();
        res.json({ message: 'User account deleted successfully' });
    } catch (error) {
        console.error('Error deleting user account:', error.message);
        res.status(500).json({ message: 'Error deleting user account', error: error.message });
    }
}),

//* Forgot password
router.post('/auth/forgot-password', async (req, res) => {
    try {
        const { email } = req.body;
        await auth.sendPasswordResetEmail(email);
        res.json({ message: 'Password reset email sent successfully' });
    } catch (error) {
        console.error('Error sending password reset email:', error.message);
        res.status(500).json({ message: 'Error sending password reset email', error: error.message });
    }
}),

//* change Password
router.put('/auth/change-password', authenticate, async (req, res) => {
    try {
        const userId = req.user.uid;
        const { newPassword } = req.body;
        if (!newPassword || newPassword.length < 8) {
            return res.status(400).json({ message: 'Password must be at least 6 characters' });
        }
        await auth.updateUser(userId, { password: newPassword });
        res.json({ message: 'Password updated successfully' });
    } catch (error) {
        console.error('Error changing password:', error.message);
        res.status(500).json({ message: 'Error changing password', error: error.message });
    }
}),

//* Fetch all users(Admin Only)
router.get('/admin/users', authenticate, checkAdmin, async (req, res) => {
    try {
        const listUsersResult = await auth.listUsers();        
        const users = listUsersResult.users.map((user) => ({
            uid: user.uid,
            email: user.email,
            displayName: user.displayName || 'No Display Name',
            customClaims: user.customClaims || {}, 
            createdAt: user.metadata.creationTime,
            lastLoginAt: user.metadata.lastSignInTime,
        }));
        res.json({ message: 'All users fetched successfully', data: users });
    } catch (error) {
        console.error('Error fetching users:', error.message);
        res.status(500).json({ message: 'Error fetching users', error: error.message });
    }
}),

//* assigning initial admin role
router.post('/assign-admin', authenticate, async (req, res) => {
    try {
        const { uid } = req.body;
        if (!uid) {
            return res.status(400).json({ message: 'UID is required' });
        }
        await auth.setCustomUserClaims(uid, { admin: true });
        res.status(200).json({ message: `Admin rights granted to user with UID: ${uid}` });
    } catch (error) {
        console.error('Error assigning admin role:', error.message);
        res.status(500).json({ message: 'Failed to assign admin role', error: error.message });
    }
});
//* Add or update custom user roles
router.post('/admin/assign-role', authenticate, checkAdmin, async (req, res) => {
    try {
        const { uid, role, value } = req.body;
        if (!uid || !role) {
            return res.status(400).json({ message: 'UID and role are required' });
        }
        const user = await auth.getUser(uid);
        const currentClaims = user.customClaims || {};
        currentClaims[role] = value;
        await auth.setCustomUserClaims(uid, currentClaims);
        res.json({ message: `Role '${role}' updated for user with UID: ${uid}`, data: currentClaims });
    } catch (error) {
        console.error('Error assigning role:', error.message);
        res.status(500).json({ message: 'Error assigning role', error: error.message });
    }
})

module.exports = router;
