const oracledb = require('oracledb');
const postRepository = {
	insert: {
		post: {
			query: `
				BEGIN
			:id:= inserts.post_insert(:post_text,'POST',:post_owner,:visibility);
			commit;
end; `,
			/**
			 * 
			 * @param {string} post_text the main text in the post
			 * @param {number} post_owner account that own the post 
			 * @param {"public"|"only me"|"friends only"|"friends except"|"only list"} visibility 
			 * @returns bind list
			 */
			bind: (
				post_text
				, post_owner
				, visibility
			) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, post_text, post_owner, visibility }
			}
		},
		media: {
			query: `
			BEGIN
			:id := inserts.media_insert(path,:post_text,:post_owner,:visibility);
			commit;
			end; `,
			/**
			 * 
			 * @param {string} path the path to media file
			 * @param {string} post_text the main text in the post
			 * @param {number} post_owner account that own the post 
			 * @param {"public"|"only me"|"friends only"|"friends except"|"only list"} visibility 
			 * @returns bind list
			 */
			bind: (
				path
				, post_text
				, post_owner
				, visibility
			) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, path, post_text, post_owner, visibility }
			}
		},
		share: {
			query: `
			begin
			:id := inserts.share_insert(:shared_post,:post_text,:post_owner,:visibility);
			commit;
			end; `,
			/**
			 * 
			 * @param {number} shared_post
			 * @param {string} post_text the main text in the post
			 * @param {number} post_owner account that own the post 
			 * @param {"public"|"only me"|"friends only"|"friends except"|"only list"} visibility 
			 * @returns bind list
			 */
			bind: (
				shared_post
				, post_text
				, post_owner
				, visibility
			) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, shared_post, post_text, post_owner, visibility }
			}
		},
		comment: {
			query: `
			begin
			:id := inserts.comment_insert(: commented_to_post:post_text,:post_owner,:visibility) id from dual`,
			/**
			 * 
			 * @param {number} commented_to_post the post which the comment is on
			 * @param {string} post_text the main text in the post
			 * @param {number} post_owner account that own the post 
			 * @param {"public"|"only me"|"friends only"|"friends except"|"only list"} visibility 
			 * @returns bind list
			 */
			bind: (
				commented_to_post
				, post_text
				, post_owner
				, visibility
			) => {
				return { id: { dir: oracledb.BIND_OUT, type: oracledb.STRING }, commented_to_post, post_text, post_owner, visibility }
			}
		}
	}
}

module.exports = postRepository