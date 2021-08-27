/** 
 *@module controllers/device 
 **/

const Device = require("../models/device");

/**
 * Perform the insertion of a new device to the database.
 * @function
 * @async
 * @param {object} device - Contains the key value pairs with the name of the table columns as key
 * @return {object} - Returns an status object with ok = true
 * @error   - Prints the error in console and return status object with ok = false
 */

const newDevice = async ( device ) => {
    try {
        await Device.sequelize.query('CALL InsertData(:table,:params)', { replacements: { table: 'devices', params: JSON.stringify(device) }});
        return {
            ok: true
        }
    } catch (error) {
        console.log('Error: ', error);
        return {
            ok: false
        }
    }
}

/**
 * Gets all devices from database.
 * @function
 * @async
 * @return {array} - Returns a device objects array
 * @error   - Prints the error in console.
 */

const getDevices = async() => {
    try {
        const devices = await Device.sequelize.query('SELECT * FROM DevicesView');

        return devices[0];
    } catch (error) {
        console.log('Error', error);
    }
}

/**
 * Update a device in the database.
 * @function
 * @async
 * @param {object} device - Contains the key value pairs with the name of the table columns as key
 * @error   - Prints the error in console.
 */

const updateDevice = async( device ) => {
    try {
        await Device.sequelize.query('CALL UpdateDevice(:params)', { replacements: {  params: JSON.stringify( device )  }});
        return {
            ok: true
        }
    } catch (error) {
        console.log('Error', error);
    }
}

/**
 * Delete a device in the database
 * @function
 * @async
 * @param {string} id - The id of the device we want to delete.
 * @return {object} - Returns an status object with ok = true
 * @error   - Prints the error in console and return status.
 */

const deleteDevice = async( id ) => {
    try {
        await Device.sequelize.query('CALL DeleteDevice(:params)', { replacements: {  params: id  }});
        return {
            ok: true
        }
    } catch (error) {
        console.log('Error', error);        
    }
}

/**
 * Force a random device to fail turning the state.turnedOn property from true to false
 * @function
 * @async
 * @return {object} - Contain the id of the device that fail.
 * @error   - Prints the error in console and return status.
 */

const stopDevice = async() =>{
    try {
        const result = await Device.sequelize.query('SELECT StopDevice() as stoped');

        const {stoped} = result[0][0];

        return{
            stoped
        };
    } catch (error) {
        console.log('Error' + error);
    }
}

module.exports = {
    newDevice,
    getDevices,
    updateDevice,
    deleteDevice,
    stopDevice
}