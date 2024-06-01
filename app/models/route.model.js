/*
    Author      :   shivam shrivastava
    Date        :   11 NOV 2023
    ModuleName  :   route.model.js
    Module      :   This module defines the model for the 'route' table.
*/

// Import the SQL connection from db.js
const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}
// Create a new route entry in the database
async function createRoute(newRoute) {

    try {
        const result = await sql.query(
            `INSERT INTO ${this.schema}.route (locationid, transportid, order_no) VALUES ($1, $2, $3) RETURNING *`,
            [newRoute.locationid, newRoute.transportid, newRoute.order_no]
        );

        if (result.rows.length > 0) {
            return { id: result.rows[0].id, ...newRoute };
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Get all routes from the database
async function getAllRoutes() {
    try {

        const result = await sql.query(`SELECT t.*, c.vehicle_no AS transport_name,
         l.location AS location_name FROM ${this.schema}.route AS t LEFT JOIN ${this.schema}.transport AS c ON
          t.transportid = c.id LEFT JOIN ${this.schema}.location_master AS l ON t.locationid = l.id`);

        return result.rows;
    } catch (error) {
        throw error;
    }
}

// Get a route by ID from the database
async function getRouteById(id) {
    try {
        const result = await sql.query(`SELECT t.*, c.vehicle_no AS transport_name,l.location AS location_name FROM ${this.schema}.route AS t LEFT JOIN transport AS c ON t.transportid = c.id LEFT JOIN location_master AS l ON t.locationid = l.id WHERE t.id = $1`, [id]);
        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Update a route by ID in the database
async function updateRoute(id, updatedRoute) {
    console.log('id, updatedRouteid, updatedRouteid, updatedRouteid==========>', id, updatedRoute);
    try {
        const result = await sql.query(
            `UPDATE ${this.schema}.route SET  locationid = $1, transportid = $2, order_no = $3 WHERE id = $4 RETURNING *`,
            [updatedRoute.locationid, updatedRoute.transportid, updatedRoute.order_no, id]
        );

        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Delete a route by id in the database
async function deleteRoute(id) {
    try {
        const result = await sql.query(
            `DELETE FROM ${this.schema}.route WHERE id = $1 RETURNING *`,
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

async function isDuplicateRoute(locationid, transportid, order_no) {
    try {
        const result = await sql.query(
            `SELECT COUNT(*) FROM ${this.schema}.route WHERE locationid = $1 AND transportid = $2 AND order_no = $3`,
            [locationid, transportid, order_no]
        );

        return parseInt(result.rows[0].count) > 0;
    } catch (error) {
        throw error;
    }
}

module.exports = {
    createRoute,
    getAllRoutes,
    getRouteById,
    updateRoute,
    deleteRoute,
    isDuplicateRoute,
    init
};