/**
 * @typedef { import("./types").email } email
 */

/**
 *  
 * @param {string} email
 * @return {email} verified email
 */
const email = (email) => {
	// if email matches an email regex return the email string
	// or throw an error
	if (email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
		return email;
	} else {
		throw new Error('Invalid email');
	}
}
