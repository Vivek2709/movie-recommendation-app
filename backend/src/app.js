const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const movieRoutes = require('./routes/movieRoutes')
const mlBasedRecommendationRoutes = require('./routes/mlBasedRecommendationRoutes')
const userRoutes = require('./routes/userRoutes')
const reviewRoutes = require('./routes/reviewRoutes')
const watchListRoutes = require('./routes/watchListRoutes')
const { authenticate,checkAdmin } = require('./middlewares/authMiddleware')


const app = express();

//*middleware
app.use(cors())
app.use(bodyParser.json())
app.use(express.json())

//* middlewares


//*routes
app.use('/movies', movieRoutes)
app.use('/users',userRoutes)
app.use('/mlservices',mlBasedRecommendationRoutes)
app.use('/reviews',reviewRoutes)
app.use('/watchlist',watchListRoutes)
/*app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ message: 'Internal Server Error', error: err.message });
});*/

module.exports = app;