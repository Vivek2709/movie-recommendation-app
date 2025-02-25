const {auth} = require ('../utils/firebase')
const {} =  require('express')
const axios = require('axios');


const authenticate = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ message: 'Unauthorized: No token provided' });
        }
        const token = authHeader.split(' ')[1];
        const decodeToken = await auth.verifyIdToken(token);
        console.log(decodeToken);
        req.user = decodeToken; // Add decoded token to request object
        next(); // Pass control to the next middleware/route handler
    } catch (error) {
        console.error('Authentication error:', error.message);
        res.status(401).json({
            message: 'Unauthorized: Invalid Token',
            error: error.message,
        });
    }
};


const checkAdmin = (req, res, next) => {
    if (!req.user.admin) {
        return res.status(403).json({ message: 'Forbidden: Admin access only' });
    }
    next();
};


module.exports = {authenticate, checkAdmin};