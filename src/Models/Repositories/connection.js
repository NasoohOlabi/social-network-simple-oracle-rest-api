const { json } = require('express');
const oracledb = require('oracledb')

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT

const dbConnection = require('../../../config/dbConnection')

const connectionAttributes = dbConnection.connAtter

/**
 * 
 * @param {string} query - the query to be executed
 * @param {object} bindParams - the bind parameters to be used in the query
 * @param {object} options - the options to be used in the query
 * @returns {Promise<{result:object?,error:object?}>} - the result of the query
 */
const db = async (query, bindParams, options = {}) => {
	try {
		console.log(`query : `);
		console.log(query);
		const connection = await oracledb.getConnection(connectionAttributes)
		console.log(`connection to database was successful`)
		const result = await connection.execute(query, bindParams, options);
		console.log(`got result ${JSON.stringify(result)}`)
		if (result.metaData === undefined
			&& result.rows === undefined
			&& result.outBinds.id) {
			console.log(`taking only the id`)
			result.id = result.outBinds.id
			delete result.outBinds
		}
		return { result, error: null }
	} catch (err) {
		console.log(`got error ${JSON.stringify(err)}`)
		return { error: err, result: null }
	}
};

module.exports = db
