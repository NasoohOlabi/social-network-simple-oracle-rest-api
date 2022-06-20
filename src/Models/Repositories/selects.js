
const __select_id = (name) => {
	return {
		query: `select * from "${name}" where "id" = :id`,
		bind: (id) => { return { id } }
	}
}
const __select_all = (name) => {
	return { query: `select * from "${name}"`, bind: () => { return {} } }
}
const __select_id_join_entity = (name) => {
	return { query: `select * from "${name}" join "entity" using("id") where active = 1 and "id" = :id`, bind: (id) => { return { id } } }
}
const __select_all_join_entity = (name) => {
	return { query: `select * from "${name}" join "entity" using("id") where active = 1`, bind: () => { return {} } }
}
const __select_id_join_entity_join_post = (name) => {
	return { query: `select * from "${name}" join "entity" using("id") join post using("id") where active = 1 and "id" = :id`, bind: (id) => { return { id } } }
}
const __select_all_join_entity_join_post = (name) => {
	return { query: `select * from "${name}" join "entity" using("id") join post using("id") where active = 1`, bind: () => { return {} } }
}


module.exports = {
	select: {
		user: __select_id('user'),
		page: __select_id('page'),
		post: __select_id_join_entity('post'),
		share: __select_id_join_entity_join_post('share'),
		media: __select_id_join_entity_join_post('media'),
		comment: __select_id_join_entity_join_post('comment'),
		event: __select_id_join_entity('event'),
		react: __select_id('react'),
		participant: __select_id('event_participant'),
		relationship: __select_id('relationship'),
		notification: __select_id('notification'),
		visibility: __select_id('visibility_user_set'),
		groupChat: __select_id('group_chat'),
		groupMember: __select_id('member'),
		message: __select_id('message')
	},
	selectAll: {
		user: __select_all('user'),
		page: __select_all('page'),
		post: __select_all_join_entity('post'),
		share: __select_all_join_entity_join_post('share'),
		media: __select_all_join_entity_join_post('media'),
		comment: __select_all_join_entity_join_post('comment'),
		event: __select_all_join_entity('event'),
		react: __select_all('react'),
		participant: __select_all('event_participant'),
		relationship: __select_all('relationship'),
		notification: __select_all('notification'),
		visibility: __select_all('visibility_user_set'),
		groupChat: __select_all('group_chat'),
		groupMember: __select_all('member'),
		message: __select_all('message')
	}
}