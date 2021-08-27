/**
 * Class with the server configuration.
 */


const express = require('express');
const cors = require('cors');

const { socketController } = require('../sockets/controller');
const deviceController = require('../sockets/controller');
const { stopDevice, getDevices } = require('../controllers/device');

class Server {

    /**
     * Initialize all the properties and call the methods
     */
    constructor() {
        this.app    = express();
        this.port   = process.env.PORT;
        this.server = require('http').createServer( this.app );
        this.io     = require('socket.io')( this.server,{ 
            cors: {
                origin: "http://localhost:3000",
                methods: ["GET", "POST", "DELETE" ]
            }
        });

        this.paths = {};
        
        // Middlewares
        this.middlewares();

        // Sockets
        this.sockets();
    }
    /**
     * Configurate the CORS and public directory
     */
    middlewares() {
        // CORS
        this.app.use( cors() );

        // Directorio Público
        this.app.use( express.static('public') );

    }

    /**
     * Stablish the socket connection and fire the device failure every 5 minutes
     */
    sockets() {

        this.io.on('connection', (socket) => {
            deviceController( socket, this.io );
        });

        setInterval( async() => {
            this.io.emit( 'stop-device', await stopDevice());
            this.io.emit( 'all-devices', await getDevices());
            
        }, 30000 );
    

    }

    /**
     * Set the server online
    */

    listen() {
        this.server.listen( this.port, () => {
            console.log('Servidor corriendo en puerto', this.port );
        });
    }

}




module.exports = Server;