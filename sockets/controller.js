/**
 * @module sockets/contoller
 */

const { newDevice, getDevices, updateDevice, deleteDevice } = require("../controllers/device");

/**
 * Manage all the socket events
 * @param {*} socket - contain the current socket
 * @param {*} io - contain the server socket
 * 
 */

const deviceController = ( socket, io ) => {
    
    ( async () => {
        socket.emit('all-devices', await getDevices() );
    })();

    socket.on( 'add-device', async( { device }, callback ) => {
        const insert_status = await newDevice( device );
        if( insert_status.ok ){
            io.emit( 'all-devices', await getDevices() );
        }
        callback( insert_status );
    });

    socket.on( 'update-device', async( { device }, callback ) =>{
        const update_status = await updateDevice( device );
        if( update_status.ok ){
            io.emit( 'all-devices', await getDevices() );
        }

        callback( update_status );

    });

   socket.on( 'delete-device', async( { id }, callback ) =>{
        const delet_status = await deleteDevice( id );

        if( delet_status ){
            io.emit( 'all-devices', await getDevices() );
        }

        callback( delet_status );
   });

    socket.on('disconcect', () => {
        console.log('User Disconected');
    });

}

module.exports = deviceController;