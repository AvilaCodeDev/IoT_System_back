const  { DataTypes } = require("sequelize");
const connection = require("../db/connection");

const db = connection();

const Device = db.define('Device', {
    id:{
        type: DataTypes.INTEGER,
        primaryKey: true
    },
    type:{
        type: DataTypes.STRING
    },
    label:{
        type: DataTypes.STRING
    },
    manufacturer:{
        type: DataTypes.STRING
    },
    state: {
        type: DataTypes.JSON
    }
});

module.exports = Device;

