
const chatRepo = require('./Repositories/chat')
const accountRepo = require('./Repositories/account')
const notificationRepo = require('./Repositories/notifications')
const postRepo = require('./Repositories/post')
const selects = require('./Repositories/selects')


// event participant relationship notification visibility groupChat groupMember message

module.exports = {
	insert: { ...chatRepo.insert, ...accountRepo.insert, ...notificationRepo.insert, ...postRepo.insert },
	select: selects.select,
	selectAll: selects.selectAll
	
}