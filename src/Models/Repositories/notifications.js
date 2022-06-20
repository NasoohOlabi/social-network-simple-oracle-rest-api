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
			bind: ({ user_id_value, type_value, item_id_value }) => {
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
			bind: ({ entityId, userId }) => {
				return {
					id: { dir: oracledb.BIND_OUT, type: oracledb.STRING },
					entityId,
					userId
				}
			}
		}
	},
	update: {
		notification: {
			query: `
				BEGIN
				update "notification" set 
					  "user_id" = :user_id
					, "type" = :type
					, "item_id" = :item_id
				where "id" = :id;
				commit;
				END;
			`,
			bind: ({ id, user_id, type, item_id }) => {
				return {
					id,
					user_id,
					type,
					item_id
				}
			}
		},
		visibility: {
			query: `
			begin
			update "visibility_user_set" set
			"entity_id"  = :entity_id 
				, "user_id"  = :user_id   
			where "id" = :id;
			commit;
			end;
			`,
			bind: ({ id, entity_id, user_id }) => {
				return {
					id,
					entity_id,
					user_id
				}
			}
		}
	}
}


module.exports = notificationRepository