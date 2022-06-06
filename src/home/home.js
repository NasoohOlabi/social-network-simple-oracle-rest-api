const express = require('express')
const db = require('../Models/BaseModel')

const router = express.Router();


router.get("/", (req, res) => {
	console.log(`endpoint / was called`)
	let myParam = +req.body.myParam;
	myParam += 1;

	const pr = require('../Models/Repositories/post')

	const v = pr.insert.post

	db(v.query, v.bind("whassup1",4,'public'), (err, result) => {

		console.log(`result: ${JSON.stringify(result)}`)
		// console.log(`result: ${JSON.stringify(result.metaData)}`)
		// console.log(`result: ${JSON.stringify(result.rows[0])}`)
		console.log(`err: ${err}`)

	})

	return res.json({ value: myParam, message: "hello world!" })
})

module.exports = router