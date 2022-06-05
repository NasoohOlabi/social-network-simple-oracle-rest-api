const oracledb = require('oracledb')

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT

const dbConnection = require('../../config/dbConnection')

const connectionAttributes = dbConnection.connAtter

/**
 * 
 * @param {string} query - the query to be executed
 * 
 */
const db = (query, bindParams, callBack, options = {}) => {
	oracledb.getConnection(connectionAttributes, (err, connection) => {
		if (err) {
			console.log(err)
			return;
		}
		console.log(`connection to database was successful`)
		connection.execute(query, bindParams, options, callBack);
	})
};

module.exports = db
