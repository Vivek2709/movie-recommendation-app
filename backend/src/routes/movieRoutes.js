const express =  require('express')
const {fetchMovieDetails} = require('../services/omdbService')
const {db} = require('../utils/firebase')
const axios = require('axios');
const { authenticate, checkAdmin } = require('../middlewares/authMiddleware');
const { sendNotification } = require('../utils/notification');
const router = express.Router()

router.get('/fetch/:title', async (req, res) => {
    try {
        const title = req.params.title;
        console.log(`Fetching movie: ${title}`);
        const movieSnapshot = await db.collection('moviesAndWebSeries')
            .where('Title', '==', title)
            .get();
        if (!movieSnapshot.empty) {
            const movieData = movieSnapshot.docs[0].data();
            return res.json({ message: 'Movie found in Firestore', data: movieData });
        }
        const movieData = await fetchMovieDetails(title);
        if (!movieData) {
            return res.status(404).json({ message: 'Movie not found in OMDB' });
        }
        const docRef = db.collection('moviesAndWebSeries').doc(movieData.imdbID);
        await docRef.set(movieData);
        console.log('Movie data saved to Firestore:', docRef.path);
        const userDocs = await db.collection('users').get();
        const tokens = userDocs.docs
            .map((doc) => doc.data().fcmToken)
            .filter((token) => token); // Only include valid tokens
        if (tokens.length > 0) {
            const notificationPayload = {
                title: 'New Movie Added!',
                body: `Check out "${movieData.Title}" now!`,
            };
            const notificationResponse = await sendNotification(tokens, notificationPayload);
            if (notificationResponse && notificationResponse.successCount !== undefined) {
            console.log(`Notifications sent: ${notificationResponse.successCount}`);
            } else {
            console.log("Error: Notification response is undefined or invalid");
            }  
        }
        res.json({ message: 'Movie fetched, saved, and notifications sent successfully', data: movieData });
    } catch (error) {
        console.error('Error fetching or saving movie:', error.message);
        res.status(500).json({ message: 'Error fetching data', error: error.message });
    }
});

//* For Search

router.get('/search', async (req,res) => {
    try{
        const query = req.query.q;
        console.log(`Searching for movies: ${query}`)
    

    //*using omdb for better search
    const response = await axios.get('http://www.omdbapi.com/',{
        params:{
            apiKey: process.env.OMDB_API_KEY,
            s: query,
        },
    })
    if(response.data.Response === 'False'){
        return res.status(404).json({message: 'No movie Found', erorr:response.data.Error});
    }
    res.json({ message: 'Moives fetched from OMDb', data: response.data.Search})
    }catch(error){
        console.error('Error in /search', error.meesage)
        res.status(500).json({message:'Error searching movies', error: error,message})
    }
    
})



router.get('/', async(req,res)=>{
    try{
        const movieSnapshot = await db.collection('moviesAndWebSeries').get();
        const movies = movieSnapshot.docs.map(doc => ({id: doc.id, ...doc.data()}));
        res.json(movies);
    } catch(error){
        res.status(500).json({message : 'Error fetching movies', error: error.message})
    }
})

//*get movie by id
router.get('/:id', async(req,res) => {
    try {
        const movieId = req.params.id;
        console.log(`Fetching movie with ID: ${movieId}`);
        const movieDoc = await db.collection('moviesAndWebSeries').doc(movieId).get();
        if (!movieDoc.exists) {
            return res.status(404).json({ message: 'Movie not found in Firestore' });
        }
        res.json({ message: 'Movie fetched from Firestore', data: movieDoc.data() });
    } catch (error) {
        console.error('Error in /:id:', error.message);
        res.status(500).json({ message: 'Error fetching movie', error: error.message });
    }
})

//* Update a Movie in firestore
router.put('/movies/:id', authenticate, checkAdmin, async(req,res) => {
    try {
        const movieId = req.params.id;
        const updateData = req.body
        if (!movieId.imdbID || !movieId.title) {
            return res.status(400).json({ message: 'imdbID and title are required' });
        }
        console.log(`Updating movie with ID: ${movieId}`);
        const movieDoc = await db.collection('moviesAndWebSeries').doc(movieId);
        await movieDoc.update(updateData)
        res.json({message: 'Movie Updated Successfully'})
        if (!movieDoc.exists) {
            return res.status(404).json({ message: 'Movie not found in Firestore' });
        }
        res.json({ message: 'Movie fetched from Firestore', data: movieDoc.data() });
    } catch (error) {
        console.error('Error in Updating Movie:', error.message);
        res.status(500).json({ message: 'Error Updating movie', error: error.message });
    }
})

//* delete a movie from firestore
router.delete('/:id', async (req, res) => {
    try {
        const movieId = req.params.id;
        console.log(`Deleting movie with ID: ${movieId}`);
        const movieDoc = db.collection('moviesAndWebSeries').doc(movieId);
        await movieDoc.delete();
        res.json({ message: 'Movie deleted successfully' });
    } catch (error) {
        console.error('Error deleting movie:', error.message);
        res.status(500).json({ message: 'Error deleting movie', error: error.message });
    }
});

//** Advanced Routes */
router.get('/filter', async(req,res) => {
    try {
        const genre = req.query.genre || null;
        const year = req.query.year || null;
        let query = db.collection('moviesAndWebSeries')
        if (genre) query = query.where('Genre', 'array-contains', genre)
        if (year) query = query.where('Year', '==', year)
        const movieSnapshot = await query.get();
        const movies = movieSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
        }))
        res.json({message: "Movies Filtered successfully"})
    } catch (error) { 
        console.error('Error Filtering movies', error.meesage);
        res.status(500).json({messgae: 'Error filtering movies'})
    }
})

//* Pupular movies
//TODO: other categories can be implemented later
router.get('/popular', async(req,res) => {
    try {
        const response = await axios.get('http://www.omdbapi.com/',{
            params: {
                apiKey: process.env.OMDB_API_KEY,
                s: 'popular',
            },
        });
        if(response.data.Response === 'False'){
            return res.status(404).json({message: 'No Popular Movies Found'});
        }
        res.json({message: 'Popular movies fetched succesfully', data: response.data.Search})
    } catch (error) {
        console.error('Error fetching popular movies:', error.message);
        res.status(500).json({message: 'Error fetching popular movies', error: error.meesage})
    }
})

//* get movies by rating
// router.get('/filter/rating', async(req,res)=>{
//     try {
//         const minRating = parseFloat(req.body.rating)
//         const movieSnapshot = await db.collection('moviesAndWebSeries')
//         .where('imdbRating', '>=', minRating)
//         .get()
//         const movies = movieSnapshot.docs.map(doc => ({
//             id: doc.id,
//             ...doc.data(),
//         }));
//         res.json({message: `Movies with rating >= ${minRating} fetched`,data: movies})
//     } catch (error) {
//         console.error('Error filtering movies by rating', error.message)
//         res.status(500).json({message: 'Error filtering by rating', error: error.message})
//     }
// })

router.get('/category/:category', async (req, res) => {
    try {
        console.log(` Incoming request to: ${req.originalUrl}`);

        const { category } = req.params;
        if (!category) {
            console.log(` No category provided!`);
            return res.status(400).json({ message: "Category is required" });
        }

        let query = db.collection('moviesAndWebSeries');
        const formattedCategory = category.charAt(0).toUpperCase() + category.slice(1).toLowerCase(); // Capitalize first letter
        console.log(`🔎 Fetching category: ${formattedCategory}`);

        switch (category.toLowerCase()) {
            case "popular":
                console.log(" Fetching popular movies...");
                query = query.orderBy('imdbRating', 'desc').limit(10);
                break;
            case "high_rated":
                console.log(" Fetching high-rated movies...");
                query = query.where('imdbRating', '>=', 8.0).orderBy('imdbRating', 'desc');
                break;
            case "action":
            case "comedy":
            case "drama":
                console.log(` Fetching '${formattedCategory}' movies...`);
                query = query.where('Genre', 'array-contains', formattedCategory).orderBy('imdbRating', 'desc');
                break;
            default:
                console.log(` Invalid category: ${category}`);
                return res.status(400).json({ message: "Invalid category" });
        }

        const movieSnapshot = await query.get();
        console.log(` Found ${movieSnapshot.size} movies in category: '${formattedCategory}'`);

        if (movieSnapshot.empty) {
            return res.status(404).json({ message: `No movies found in '${formattedCategory}' category` });
        }

        const movies = movieSnapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data(),
            imdbRating: parseFloat(doc.data().imdbRating) // Ensure imdbRating is a float
        }));

        res.json({ message: `Movies in '${formattedCategory}' category fetched successfully`, data: movies });
    } catch (error) {
        console.error(' Error fetching category movies:', error.stack);
        res.status(500).json({ message: 'Error fetching movies', error: error.message });
    }
});





module.exports = router;