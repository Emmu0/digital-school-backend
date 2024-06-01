/*
    Author      :   Shivam Shrivastava
    Date        :   24-09-2023
    ModuleName  :   locationmaster.model.js
    Module      :   This module added by Shivam shrivastava for managing location master
*/

// Import the SQL connection from db.js
const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}
// Create a new location entry in the database
async function createLocation(newLocation) {

    try {
        const result = await sql.query(
            `INSERT INTO ${this.schema}.Location_Master (location, distance, status) VALUES ($1, $2, $3) RETURNING *`,
            [newLocation.location, newLocation.distance, newLocation.status]
        );

        if (result.rows.length > 0) {
            return { id: result.rows[0].id, ...newLocation };
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Get all locations from the database
async function getAllLocations() {
    try {
        const result = await sql.query(`SELECT * FROM ${this.schema}.Location_Master`);
        return result.rows;
    } catch (error) {
        throw error;
    }
}

// Get a location by ID from the database
async function getLocationById(id) {
    try {
        const result = await sql.query(`SELECT * FROM ${this.schema}.Location_Master WHERE id = $1`, [id]);
        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Update a location by ID in the database
async function updateLocation(id, updatedLocation) {
    try {
        const result = await sql.query(
            `UPDATE ${this.schema}.Location_Master SET location = $1, distance = $2, status = $3 WHERE id = $4 RETURNING *`,
            [updatedLocation.location, updatedLocation.distance, updatedLocation.status, id]
        );

        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Delete a location by id in the databse
async function deleteLocation(id) {
    try {
        const result = await sql.query(
            `DELETE FROM ${this.schema}.Location_Master WHERE id = $1 RETURNING *`,
            [id]
        );

        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

async function checkDuplicateLocation(newLocation) {
    try {
        const result = await sql.query(
            `SELECT COUNT(*) FROM ${this.schema}.Location_Master WHERE location = $1 AND distance = $2 AND status = $3`,
            [newLocation.location, newLocation.distance, newLocation.status]
        );

        return parseInt(result.rows[0].count) > 0;
    } catch (error) {
        throw error;
    }
}


module.exports = {
    createLocation,
    getAllLocations,
    getLocationById,
    updateLocation,
    deleteLocation,
    checkDuplicateLocation,
    init
};
