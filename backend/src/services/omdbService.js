const axios = require('axios');
const {} = require('express');

const fetchMovieDetails = async (title) => {
    try {
        const apiKey = process.env.OMDB_API_KEY;
        const response = await axios.get(`http://www.omdbapi.com/`, {
            params: {
                apiKey: apiKey,
                t: title
            },
        });
        if (response.data.Response === 'False') {
            throw new Error(response.data.Error);
        }
        let movieData = response.data;
        movieData.imdbRating = movieData.imdbRating ? parseFloat(movieData.imdbRating) : 0;
        movieData.Genre = movieData.Genre ? movieData.Genre.split(", ").map(g => g.trim()) : [];

        return movieData;
    } catch (error) {
        console.error('Error fetching movie data:', error.message);
        throw error;
    }
};





module.exports = {fetchMovieDetails};