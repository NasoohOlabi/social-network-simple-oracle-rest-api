const oracledb = require('oracledb');
const postRepository = {
	insert: {
		post: {
			query: `
				BEGIN
			:id:= post_insert(:text,'POST',:post_owner,:visibility);
			commit;
end; `,
			/**
			 * 
			 * @param {string} text the main text in the post
			 * @param {number} post_owner account that own the post 
			 * @param {"public"|"only me"|"friends only"|"friends except"|"only list"} visibility 
			 * @returns bind list
			 */
			bind: ({
				text
				, post_owner
				, visibility
			}) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, text, post_owner, visibility }
			}
		},
		media: {
			query: `
			BEGIN
			:id := media_insert(path,:text,:post_owner,:visibility);
			commit;
			end; `,
			/**
			 * 
			 * @param {string} path the path to media file
			 * @param {string} text the main text in the post
			 * @param {number} post_owner account that own the post 
			 * @param {"public"|"only me"|"friends only"|"friends except"|"only list"} visibility 
			 * @returns bind list
			 */
			bind: ({
				path
				, text
				, post_owner
				, visibility
			}) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, path, text, post_owner, visibility }
			}
		},
		share: {
			query: `
			begin
			:id := share_insert(:shared_post,:text,:post_owner,:visibility);
			commit;
			end; `,
			/**
			 * 
			 * @param {number} shared_post
			 * @param {string} text the main text in the post
			 * @param {number} post_owner account that own the post 
			 * @param {"public"|"only me"|"friends only"|"friends except"|"only list"} visibility 
			 * @returns bind list
			 */
			bind: ({
				shared_post
				, text
				, post_owner
				, visibility
			}) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, shared_post, text, post_owner, visibility }
			}
		},
		comment: {
			query: `
			begin
			:id := comment_insert(: commented_to_post:text,:post_owner,:visibility) id from dual`,
			/**
			 * 
			 * @param {number} commented_to_post the post which the comment is on
			 * @param {string} text the main text in the post
			 * @param {number} post_owner account that own the post 
			 * @param {"public"|"only me"|"friends only"|"friends except"|"only list"} visibility 
			 * @returns bind list
			 */
			bind: ({
				commented_to_post
				, text
				, post_owner
				, visibility
			}) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, commented_to_post, text, post_owner, visibility }
			}
		},
		react: {
			query: `
			begin
			:id := react_insert(:react_post_id,:react_user_id,:react_type);
			commit;
			end; `,
			/**
			 * 
			 * @param {number} react_post_id the post which the react is on
			 * @param {string} react_user_id the type of react
			 * @param {number} react_type account that own the post
			 * @returns bind list
			 * @throws {Error} if react_user_id is not one of the following: "like", "love", "haha", "wow", "sad", "angry"
			 */
			bind: ({
				react_post_id
				, react_user_id
				, react_type
			}) => {
				if (react_user_id !== "like" && react_user_id !== "love" && react_user_id !== "haha" && react_user_id !== "wow" && react_user_id !== "sad" && react_user_id !== "angry") {
					throw new Error("react_user_id is not one of the following: \"like\", \"love\", \"haha\", \"wow\", \"sad\", \"angry\"");
				}
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, react_post_id, react_user_id, react_type }
			}
		}
	},
	update: {
		post: {
			query: `
				BEGIN
				update "post" set
					"text" = :text
				where "id" = :id;
					commit;
				end; `,
			bind: ({
				id,
				text
			}) => {
				return { id, text }
			}
		},
		media: {
			query: `
			BEGIN
			update "media" set
				"path" = :path
			where "id" = :id;
			update "post" set
				"text" = :text
			where "id" = :id
			commit;
			end;`,
			bind: ({
				path
				, text
				, id
			}) => {
				return { id, path, text }
			}
		},
		share: {
			query: `
			BEGIN
			update "share" set
				"post_id" = :post_id
			where "id" = :id;
			update "post" set
				"text" = :text
			where "id" = :id
			commit;
			end;`,
			bind: ({
				post_id
				, text
				, id
			}) => {
				return { id, post_id, text }
			}
		},
		comment: {
			query: `
			BEGIN
			update "share" set
				"post_id" = :post_id,
				"text" = :text
			where "id" = :id;
			commit;
			end;
			`,
			bind: ({
				post_id
				, text
				, id
			}) => {
				return { id, post_id, text }
			}
		},
		react: {
			query: `
			begin
			update "react" set
				"post_id" = :post_id,
				"user_id" = :user_id,
				"type" = :type
			where "id" = :id;
			commit;
			end; `,
			bind: ({
				post_id
				, user_id
				, type
				, id
			}) => {
				if (type !== "like" && type !== "love" && type !== "haha" && type !== "wow" && type !== "sad" && type !== "angry") {
					throw new Error("type is not one of the following: \"like\", \"love\", \"haha\", \"wow\", \"sad\", \"angry\"");
				}
				return { id, post_id, user_id, type }
			}
		}
	}
}

module.exports = postRepository