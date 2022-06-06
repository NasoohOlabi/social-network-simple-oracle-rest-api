const oracledb = require('oracledb');
const accountRepository = {
	insert:
	{
		page: {
			query: `
				BEGIN
				:id := INSERTS.PAGE_INSERT(:name);
				commit;
				END;
			`,
			/**
			 * 
			 * @param {string} name page name
			 * @returns 
			 */
			bind: (name) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, name }
			}
		}
	}
}

module.exports = accountRepository