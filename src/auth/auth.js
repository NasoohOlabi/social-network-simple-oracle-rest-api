const jwt = require('jsonwebtoken');
const db = require('../Models/Repositories/connection')
const md5 = require('md5');
const { json } = require('express');

const secretKey = '123456789'
const secretKeyRefresh = 'asdfghj'
const accessTokenExpiration = 60
const refreshTokenExpiration = '1h'


const getNewRefreshToken = async (toStore) => {
	console.log(`creating new refresh token with userInfo : `);
	console.log(toStore);
	const generatedToken = await jwt.sign(toStore, secretKeyRefresh, { expiresIn: refreshTokenExpiration });
	console.log(`generatedToken : `);
	console.log(generatedToken);
	const persistRefreshToken = await db(`begin 
			UPDATE "jwt" SET "token" = :token WHERE "id" = :id;
			commit;
			end;`, { id: toStore.id, token: generatedToken })
	if (Object.keys(persistRefreshToken.error).length > 0) {
		throw new Error("couldn't save " + JSON.stringify(persistRefreshToken.error))
	}
	return generatedToken
}


const verifyToken = async (req, res, next) => {


	const bearerHeaderSplit = req.headers['authorization'] && req.headers['authorization'].split(' ');
	let token = '';

	if (typeof bearerHeaderSplit !== 'undefined'
		&& bearerHeaderSplit[0] === 'Bearer') {
		const bearerToken = bearerHeaderSplit[1];
		token = bearerToken;
		console.log(`received token: ${token}`)

		// next();
	} else {
		return res.json({ success: false, error: 'Invalid Token' })
	}

	if (!token) {
		return res.json({ success: false, error: 'Invalid Token' })
	}


	jwt.verify(token, secretKey, async (err, decoded) => {
		if (err) {
			console.log(`got err : `);
			if (err.name === 'TokenExpiredError')
				console.log(`just expiration no bigy`)
			else
				console.log(err);
			if (err.name === 'TokenExpiredError') {
				const payload = await jwt.verify(token, secretKey, { ignoreExpiration: true });

				console.log(`payload : `);
				console.log(payload);

				// decoded = JSON.parse(payload)
				decoded = payload

				if (req.body.refreshToken) {
					try {
						const decodedRefresh = await jwt.verify(req.body.refreshToken, secretKeyRefresh)
						if (decoded.id === decodedRefresh.id) {
							const q = await db(`SELECT * FROM "jwt" WHERE "id"=:id`, { id: decoded.id })

							console.log(`q.result : `);
							console.log(q.result);

							console.log(`receivedToken`)
							console.log(req.body.refreshToken);

							console.log(`oldToken : `);
							console.log(q.result.rows[0].token)

							if (req.body.refreshToken !== q.result.rows[0].token) {
								return res.json({ success: false, message: "given refresh token doesn't match" })
							}

							console.log(`{ ...decodedRefresh } : `);
							console.log({ ...decodedRefresh });

							const newToken = await jwt.sign({ id: decodedRefresh.id }, secretKey, { expiresIn: accessTokenExpiration });
							const NewRefreshToken = await getNewRefreshToken({ id: decodedRefresh.id })

							console.log(`generated the new token ${newToken}`)


							return res.json({
								message: "here's the new token use it!"
								, succuss: true
								, accessToken: newToken
								, refreshToken: NewRefreshToken
							})

						} else {
							return res.json({ success: false, error: "inconsistent invalid tokens" })
						}
					} catch (e) {
						// too loong time even refresh expired
						return res.json({ success: false, error: 'login again please', tech: e })
					}
				}

			}
		}
		console.log(`decoded : `);
		console.log(decoded);
		req.locals = decoded;
		next();
	})

}

const login = async (req, res) => {
	console.log(`endpoint /login was called get`)
	const { email, password } = req.body

	const ans = await db(`SELECT * FROM "user" WHERE "email" = :email and "passwordHash" = :password`, { email, password: md5(password) })

	if (ans.result && ans.result.rows && ans.result.rows.length === 1) {

		const userInfo = ans.result.rows[0]

		const storedUserInfo = { id: userInfo.id }

		try {
			const accessToken = await jwt.sign(storedUserInfo, secretKey, { expiresIn: accessTokenExpiration });
			const refreshToken = await getNewRefreshToken(storedUserInfo)

			return res.json({
				success: true
				, accessToken
				, refreshToken
			})
		} catch (err) {
			return res.json({ success: false, error: err })
		}

	} else {

		return res.json({ success: false, error: 'Invalid Token' })
	}
}

const signup = async (req, res) => {
	console.log(`endpoint /signup was called get`)
	const pr = require('../Models/Model')
	const insert = pr.insert['user']

	// user_insert('mike', 'mk', 'heck', 'uname', '2135', 'he@fart', '123', '','');
	// commit;
	// End;
	// /

	const ans = await db(insert.query, insert.bind({ ...req.body, passwordHash: md5(req.body.password) }))
	if (ans.result && ans.result.id) {
		return res.json({ success: true })
	} else {
		return res.json({ success: false, error: ans.error })
	}
}


module.exports = { verifyToken, login, signup }