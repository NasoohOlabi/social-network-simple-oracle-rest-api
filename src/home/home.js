const express = require('express')
const db = require('../Models/Repositories/connection')
const auth = require('../auth/auth')

const router = express.Router();



router.post('/login', auth.login)
router.post('/signup', auth.signup)
router.get('/whoami', auth.verifyToken, async (req, res) => {
	console.log(`endpoint /whoami was called get`)
	const pr = require('../Models/Model')
	const select = pr.select.user
	if (req.locals.id)
		return res.json(await db(select.query, select.bind(req.locals.id)))
	else return res.json({ success: false, msg: "you're not supposed to be here" })
})

router.get("/:table/:id", auth.verifyToken, async (req, res) => {
	console.log(`endpoint /${req.params.table}/${req.params.id} was called get`)
	// let myParam = +req.body.myParam;
	// myParam += 1;
	const pr = require('../Models/Model')
	const select = pr.select[req.params.table]
	return res.json(await db(select.query, select.bind(req.params.id)))
})

router.get("/:table", auth.verifyToken, async (req, res) => {
	console.log(`endpoint /${req.params.table} was called get`)
	const pr = require('../Models/Model')
	const select = pr.selectAll[req.params.table]
	return res.json(await db(select.query, select.bind()))
})

router.post("/:table", auth.verifyToken, async (req, res) => {
	console.log(`endpoint /${req.params.table} was called post`)
	const pr = require('../Models/Model')
	if (req.params.table === 'user') {
		return res.json({ success: false, error: 'You can not create user like this use signup' })
	}
	const insert = pr.insert[req.params.table]
	// return res.json({ body: req.body, insert })
	return res.json(await db(insert.query, insert.bind(req.body)))
})

router.delete("/:table/:id", auth.verifyToken, async (req, res) => {
	console.log(`endpoint /${req.params.table}/${req.params.id} was called delete`)
	// let myParam = +req.body.myParam;
	// myParam += 1;
	const pr = require('../Models/Model')
	const deletes = pr.delete[req.params.table]
	if (deletes) {
		return res.json(await db(deletes.query, deletes.bind(req.params.id)))
	}
	return res.json({ error: "Can't delete whatever this is" })
})

router.put("/:table", auth.verifyToken, async (req, res) => {
	console.log(`endpoint /${req.params.table} was called put`)
	const pr = require('../Models/Model')
	const update = pr.update[req.params.table]
	return res.json(await db(update.query, update.bind(req.body)))
})

module.exports = router