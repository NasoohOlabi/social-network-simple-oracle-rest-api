const oracledb = require('oracledb');
const chatRepository = {
	insert:
	{
		GroupChat: {
			query: `
				BEGIN
				:id := group_chat_insert(:group_name);
				commit;
				END;
			`,
			/**
			 * 
			 * @param {string} group_name the name of the group
			 * @returns bind list
			 */
			bind: ({group_name}) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, group_name }
			}
		},
		GroupMember: {
			query: `
				BEGIN
				:id := member_insert(:account, :group, :role);
				commit;
				end;
			`
			,
			/**
			 * 
			 * @param {number} account who are you adding
			 * @param {number} group where are you adding him
			 * @param {string} role is he and admin, joker, talker...
			 * @returns bind list
			 */
			bind: ({account, group, role}) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, account, group, role}
			}
		},
		Message: {
			query: `
				begin
				:id := message_insert(:sender,:text, :chat)
				commit;
				end;
				`,
			/**
			 * 
			 * @param {number} sender 
			 * @param {string} text 
			 * @param {number} chat 
			 * @returns bind list
			 */
			bind: ({sender, text, chat}) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, sender, text, chat}
			}
		}
	}
}

module.exports = chatRepository