/**
 * Database Connection
 * @module db/connection
**/

const { Sequelize } = require("sequelize");

/**
 * Stablishe the mariadb conection
 * @function
 * @return - Return the new connection.
 * @error - Throw an connection error and print a message in console.
 */

const connection = () => {
    try {
        return new Sequelize( process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
            host: process.env.DB_HOST,
            dialect: 'mariadb'
        });
    } catch (error) {
        // console.log(error)
        // throw new Error('Can not connecto to the database');
    }
}


module.exports = connection;
