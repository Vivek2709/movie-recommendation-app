const express =  require('express')
const {fetchMovieDetails} = require('../services/omdbService')
const {db} = require('../utils/firebase')
const axios = require('axios');
const { authenticate } = require('../middlewares/authMiddleware');

const router = express.Router()

//* Watchlist Routes 


//* Add to watchlist 
router.post('/watchlist/:uid',authenticate, async (req, res) => {
    try {
        const { movieId } = req.body;
        const uid = req.params.uid;
        const watchlistRef = db.collection('userWatchlists').doc(uid);
        const watchlistDoc = await watchlistRef.get();
        const watchlist = watchlistDoc.exists ? watchlistDoc.data().movies || [] : [];
        if (!watchlist.includes(movieId)) {
            watchlist.push(movieId);
            await watchlistRef.set({ movies: watchlist });
        }
        res.json({ message: 'Movie added to watchlist', data: watchlist });
    } catch (error) {
        console.error('Error adding to watchlist:', error.message);
        res.status(500).json({ message: 'Error adding to watchlist', error: error.message });
    }
});

//* Fetch watchList
router.get('/watchlist/:uid',authenticate, async (req, res) => {
    try {
        const uid = req.params.uid;
        const watchlistDoc = await db.collection('userWatchlists').doc(uid).get();
        if (!watchlistDoc.exists) {
            return res.json({ message: 'No watchlist found', data: [] });
        }
        res.json({ message: 'Watchlist fetched successfully', data: watchlistDoc.data().movies });
    } catch (error) {
        console.error('Error fetching watchlist:', error.message);
        res.status(500).json({ message: 'Error fetching watchlist', error: error.message });
    }
});

//* Remove From watchlist
router.delete('/watchlist/:uid',authenticate, async (req, res) => {
    try {
        const { movieId } = req.body;
        const uid = req.params.uid;
        const watchlistRef = db.collection('userWatchlists').doc(uid);
        const watchlistDoc = await watchlistRef.get();
        if (!watchlistDoc.exists) {
            return res.status(404).json({ message: 'Watchlist not found' });
        }
        const watchlist = watchlistDoc.data().movies || [];
        const updatedWatchlist = watchlist.filter(id => id !== movieId);
        await watchlistRef.set({ movies: updatedWatchlist });
        res.json({ message: 'Movie removed from watchlist', data: updatedWatchlist });
    } catch (error) {
        console.error('Error removing from watchlist:', error.message);
        res.status(500).json({ message: 'Error removing from watchlist', error: error.message });
    }
});
module.exports = router;

