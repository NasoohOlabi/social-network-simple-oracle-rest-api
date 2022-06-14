const oracledb = require('oracledb');
/**
 * @typedef { import("../types").email } email
 */

const accountRepository = {
	insert:
	{
		page: {
			query: `
				BEGIN
				:id := PAGE_INSERT(:name);
				commit;
				END;
			`,
			/**
			 * 
			 * @param {string} name page name
			 * @returns 
			 */
			bind: ({ name }) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, name }
			}
		},
		user: {
			query: `
				BEGIN
				:id := USER_INSERT(
					:first_name,
        			:middle_name ,
        			:last_name   ,
        			:username    ,
        			:mobile      ,
        			:email       ,
        			:passwordHash,
        			:intro       ,
        			:profile     
					);
				commit;
				END;
			`,
			/**
			 * 
			 * @param {string} first_name first name
			 * @param {string|null} middle_name middle name
			 * @param {string} last_name last name
			 * @param {string} username username
			 * @param {string} mobile mobile
			 * @param {email} email 
			 * @param {string} passwordHash 
			 * @param {string|null} intro 
			 * @param {string|null} profile 
			 */
			bind: ({ first_name,
				middle_name,
				last_name,
				username,
				mobile,
				email,
				passwordHash,
				intro,
				profile }) => { }
		},
		event: {
			query: `
				BEGIN
				:id := EVENT_INSERT(
					:name,
					:timing,
					:owner,
					:visibility
					);
				commit;
				END;
			`,
			/**
			 * 	
			 * @param {string} name event name
			 * @param {string} timing event timing
			 * @param {number} owner event owner
			 * @param {number} visibility event visibility
			 * @returns bind list
			 * @memberof accountRepository
			 * @returns {object} bind list
			 */
			bind: ({ name, timing, owner, visibility }) => {
				return {
					id: { dir: oracledb.BIND_OUT, type: oracledb.STRING },
					name,
					timing,
					owner,
					visibility
				}
			}
		},
		participant: {
			query: `
				BEGIN
				:id := PARTICIPANT_INSERT(
					  :eventId
						, :userId
						);
							
				commit;
				END;
			`,
			/**
			 * 
			 * @param {number} eventId event id
			 * @param {number} userId user id
			 * @memberof accountRepository
			 * @returns {object} bind list
			 */
			bind: ({ eventId, userId }) => {
				return {
					id: { dir: oracledb.BIND_OUT, type: oracledb.STRING },
					eventId,
					userId
				}
			}
		},
		relationship: {
			query: `
				BEGIN
				:id := RELATIONSHIP_INSERT(
					:sourceId           
					, :targetId           
					, :relationship_type  
					, :relationship_status
					, :relationship_notes 
					);
				commit;
				END;
			`,
			/**
			 * 
			 * @param {number} sourceId source id
			 * @param {number} targetId target id
			 * @param {string} relationship_type relationship type
			 * @param {string} relationship_status relationship status
			 * @param {string} relationship_notes relationship notes
			 * @returns bind list
			 * @memberof accountRepository
			 * @returns {object} bind list
			 */
			bind: ({ sourceId, targetId, relationship_type, relationship_status, relationship_notes }) => {
				return {
					id: { dir: oracledb.BIND_OUT, type: oracledb.STRING },
					sourceId,
					targetId,
					relationship_type,
					relationship_status,
					relationship_notes
				}
			}

		}
	}
}



module.exports = accountRepository