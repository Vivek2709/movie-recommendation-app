const express =  require('express')
const {fetchMovieDetails} = require('../services/omdbService')
const {db} = require('../utils/firebase')
const axios = require('axios');

const router = express.Router()
const apiKey = process.env.OMDB_API_KEY


//TODO: Implement ML and then revisit the routes for update

//* recommendation on user Preferences

router.get('/reommendations/:userId', async(req,res) => {
    try {
        const userId = req.params.userId;
        const userPreferences = await db.collection('userPreferences').doc(userId).get();
        if(!userPreferences.exists){
            return res.status(400).json({message: 'User Preferences not found'});
        }
        //TODO: Calling ml model with user data
        const recommendations = await axios.post('http://localhost:5001/recommend',{
            preferences: userPreferences.data()
        });
        res.json({messgae: 'Recommendations fetche successfully',data: recommendations.data})
    } catch (error) {
        console.error('Error Fetching reommendations', error.message)
        res.status(500).json({message: 'Error fetchinf recommendations', error: error.message})
    }
})
//*TODO: understand and implement ML Later
//* For training Ml Model
router.post('/recommendations/train', async (req, res) => {
    try {
        const response = await axios.post('http://localhost:5001/train'); // Assume your ML service is hosted locally
        res.json({ message: 'Model trained successfully', data: response.data });
    } catch (error) {
        console.error('Error training model:', error.message);
        res.status(500).json({ message: 'Error training model', error: error.message });
    }
});
//* Saving user prefrences for future
router.post('/preferences/:userId', async (req, res) => {
    try {
        const userId = req.params.userId;
        const preferences = req.body;

        const userRef = db.collection('userPreferences').doc(userId);
        await userRef.set(preferences);

        res.json({ message: 'Preferences saved successfully' });
    } catch (error) {
        console.error('Error saving preferences:', error.message);
        res.status(500).json({ message: 'Error saving preferences', error: error.message });
    }
});

module.exports = router;
