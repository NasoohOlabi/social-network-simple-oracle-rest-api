const oracledb = require('oracledb');
/**
 * @typedef { import("../types").email } email
 */

const notificationRepository = {
	insert:
	{
		notification: {
			query: `

				BEGIN
				:id := NOTIFICATION_INSERT(
					  :user_id_value 
					, :type_value    
					, :item_id_value 
					);
				commit;
				END;
			`,
			/**
			 * 	
			 * @param {number} user_id_value user id
			 * @param {string} type_value type
			 * @param {number} item_id_value item id
			 * @memberof notificationRepository
			 * @returns {object} bind list
			 */
			bind: ({user_id_value, type_value, item_id_value}) => {
				return {
					id: { dir: oracledb.BIND_OUT, type: oracledb.STRING },
					user_id_value,
					type_value,
					item_id_value
				}
			}
		},
		visibility: {
			query: `
			begin
			:id = VISIBILITY_INSERT(
				  :entityId 
				, :userId   
				);
			commit;
			end;
			`,
			/**
			 * 
			 * @param {number} entityId entity id
			 * @param {number} userId user id
			 * @memberof notificationRepository
			 * @returns {object} bind list
			 */
			bind: ({entityId, userId}) => {
				return {
					id: { dir: oracledb.BIND_OUT, type: oracledb.STRING },
					entityId,
					userId
				}
			}
		}

	}
}


module.exports = notificationRepository