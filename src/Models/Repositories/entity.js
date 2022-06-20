const oracledb = require('oracledb');
const deleteEntityQuery = {
	query: `
		BEGIN
			delete_entity(:id);
			commit;
		END;`,
	bind: (id) => {
		return {
			id
		};
	}

}
const entityRepository = {
	delete: {
		post: deleteEntityQuery,
		media: deleteEntityQuery,
		share: deleteEntityQuery,
		comment: deleteEntityQuery
	}
}

module.exports = entityRepository