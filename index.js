const express = require('express')

const app = express();

app.use(express.json());

app.use(express.urlencoded({
	extended: true
}));

const router = require('./src/home/home')

app.use(router)

const port = 5000;

app.listen(port, () => {
	console.log(`the web server is ready on port: ${port}`)
})