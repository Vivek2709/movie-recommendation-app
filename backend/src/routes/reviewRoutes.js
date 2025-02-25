const express =  require('express')
const {fetchMovieDetails} = require('../services/omdbService')
const {db} = require('../utils/firebase')
const axios = require('axios');

const router = express.Router()

//* Review And Rating Routes

router.post('/reviews/:moviID', async (req,res) => {
    try{
        const {uid, rating, review} = req.body;
        const movieId = req.params.moviID;

        const reviewRef = db.collection('moviesAndWebSeries').doc(movieId).collection('reviews').doc();
        await reviewRef.set({uid, rating, review, createdAt: new Date()});
        res.json({message: 'Review Added Successfully'})
    }catch(error){
        console.error('Errod addind review', error.message)
        res.status(500).json({message: 'Error adding review', error: error.message})
    }
})

//* Fetch Reviews For a Movie
router.get('/reviews/:moiveId', async(req,res) => {
    try{
        const movieId = req.params.moiveId
        const reviewSnapshot = await db.collection('moviesAndWebSeries').doc(movieId).collection('reviews').get()
        const reviews = reviewSnapshot.docs.map(doc => ({
            id:doc.id,
            ...doc.data()
        }))
        res.json({message: 'Reviews fetched Succssfully'}, reviews)
    }catch(error){
        console.error('Error fetching reviews',error.message)
        res.status(500).json({message:'Error fetching reviews', error:error.message})
    }
})

//*Edit a review
router.put('/reviews/:movieId/:reviewId', async(req,res)=>{
    try{
        const {rating,review} = req.body;
        const {movieId,reviewId} = req.params;
        const reviewRef = db.collection('moviesAndWebSeries').doc(movieId).collection('reviews').doc(reviewId);
        await reviewRef.update({rating,review, updateAt: new Date()});
        res.json({message:'Review Updated Successfully'});
    }catch(error){
        console.error('Error Updating Review',error.message)
        res.status(500).json({message: 'Error Updating review', error: error.message})
    }
})

//*Delete A review
router.delete('/reviews/:movieId/:reviewId', async(req,res) => {
    try{
        const {movieId, reviewId} = req.params;
        const reviewRef = db.collection('moviesAndWebSeries').doc(movieId).collection('reviews').doc(reviewId)
        await reviewRef.delete()
        res.json({message: 'Review deleted Succsessfully'})
    }catch(error){
        console.error('Error deleting review',error.message)
        res.status(500).json({
            message: 'Error deleting review',
            error: error.message
        })
    }
})

//* Average Rating
router.get('/movies/ratings/:movieId', async (req, res) => {
    try {
        const movieId = req.params.movieId;
        const reviewsSnapshot = await db.collection('moviesAndWebSeries')
            .doc(movieId)
            .collection('reviews')
            .get();
        const reviews = reviewsSnapshot.docs.map(doc => doc.data());
        const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
        const averageRating = reviews.length ? totalRating / reviews.length : 0;
        res.json({ message: 'Average rating fetched', data: { averageRating, totalReviews: reviews.length } });
    } catch (error) {
        console.error('Error fetching average rating:', error.message);
        res.status(500).json({ message: 'Error fetching average rating', error: error.message });
    }
});

module.exports = router;
