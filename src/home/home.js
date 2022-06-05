const express = require('express')
const db = require('../Models/BaseModel')

const router = express.Router();


router.get("/", (req, res) => {
	console.log(`endpoint / was called`)
	let myParam = +req.body.myParam;
	myParam += 1;

	db("select * from employees", {}, (err, result) => { 

		console.log(`result: ${result}`)
		console.log(`err: ${err}`)

	})

	return res.json({ value: myParam, message: "hello world!" })
})

module.exports = router