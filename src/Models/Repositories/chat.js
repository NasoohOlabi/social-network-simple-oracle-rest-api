const oracledb = require('oracledb');
const chatRepository = {
	insert:
	{
		GroupChat: {
			query: `
				BEGIN
				:id := group_chat_insert(:name);
				commit;
				END;
			`,
			bind: ({ name }) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, name }
			}
		},
		GroupMember: {
			query: `
				BEGIN
				:id := member_insert(:account_id, :group_chat_id, :type);
				commit;
				end;
			`
			,
			bind: ({ account_id, group_chat_id, type }) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, account_id, group_chat_id, type }
			}
		},
		Message: {
			query: `
				begin
				:id := message_insert(:message_from,:message, :chat_id)
				commit;
				end;
				`,
			bind: ({ message_from, message, chat_id }) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, message_from, message, chat_id }
			}
		}
	},
	update:
	{
		GroupChat: {
			query: `
				BEGIN
				update "group_chat" set "name" = :name
				where "id" = :id;
				commit;
				END;
			`,
			bind: ({ name }) => {
				return { id, name }
			}
		},
		GroupMember: {
			query: `
				BEGIN
				update "member" set "account_id" = :account_id, "group_chat_id" = :group_chat, "type" = :type
				where "id" = :id;
				commit;
				end;
			`,
			bind: ({ account_id, group_chat_id, type }) => {
				return { id, account_id, group_chat_id, type }
			}
		},
		Message: {
			query: `
				begin
				update "message" set "message_from" = :message_from, "message" = :message, "chat_id" = :chat_id
				where "id" = :id;
				commit;
				end;
				`,
			bind: ({ id, message_from, message, chat_id }) => {
				return { id, message_from, message, chat_id }

			}
		}
	}
}

module.exports = chatRepository