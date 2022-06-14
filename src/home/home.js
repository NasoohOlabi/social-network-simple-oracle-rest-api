const express = require('express')
const db = require('../Models/Repositories/connection')

const router = express.Router();


router.get("/:table/:id", async (req, res) => {
	console.log(`endpoint /${req.params.table}/${req.params.id} was called get`)
	// let myParam = +req.body.myParam;
	// myParam += 1;
	const pr = require('../Models/Model')
	const select = pr.select[req.params.table]
	return res.json(await db(select.query, select.bind(req.params.id)))
})

router.get("/:table", async (req, res) => {
	console.log(`endpoint /${req.params.table} was called get`)
	const pr = require('../Models/Model')
	const select = pr.selectAll[req.params.table]
	return res.json(await db(select.query, select.bind()))
})

router.post("/:table", async (req, res) => {
	console.log(`endpoint /${req.params.table} was called post`)
	const pr = require('../Models/Model')
	const insert = pr.insert[req.params.table]
	// return res.json({ body: req.body, insert })
	return res.json(await db(insert.query, insert.bind(req.body)))
})

module.exports = router



	// const results = [];

	// for (let vv in select) {
	// 	console.log(select[vv].query)
	// 	const b = select[vv].bind(3)
	// 	console.log(`b : `);
	// 	console.log(b);
	// 	const sth = await db(select[vv].query, b)
	// 	results.push(sth)
	// }
	// const { result, error } = await db(select.query, select.bind("whassup1", 4, 'public'))
	// const { result, error } = await db(`select * from post`, {})