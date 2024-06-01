/*
    Author      :   Shivam Shrivastava
    Date        :   24-09-2023
    ModuleName  :   faremaster.model.js
    Module      :   This module added by Shivam shrivastava for using fare master
*/
//<-----------------FareMaster by Insert  ------------------>
// Import the SQL connection from db.js
const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}
// Insert Fare into the database
async function insertFare(newFare) {
    try {
        const result = await sql.query(
            `INSERT INTO ${this.schema}.Fare_Master (Fare, FromDistance, ToDistance, Status) VALUES ($1, $2, $3, $4) RETURNING *`,
            [newFare.Fare, newFare.FromDistance, newFare.ToDistance, newFare.Status]
        );

        if (result.rows.length > 0) {
            return { id: result.rows[0].id, ...newFare };
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// Get all Fares from the database
async function getAllFares() {
    try {
        const result = await sql.query(`SELECT * FROM ${this.schema}.Fare_Master`);
        return result.rows;
    } catch (error) {
        throw error;
    }
}

// Get a Fare by ID from the database
async function getFareById(id) {
    try {
        const result = await sql.query(`SELECT * FROM ${this.schema}.Fare_Master WHERE id = $1`, [id]);
        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

//Delete a fare by id from the database
async function deleteFare(id) {
    try {
        const result = await sql.query(
            `DELETE FROM ${this.schema}.Fare_Master WHERE id = $1 RETURNING *`,
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

// Update a Fare by ID in the database
async function updateFare(id, updatedFare) {
    try {
        const result = await sql.query(
            `UPDATE ${this.schema}.Fare_Master SET Fare = $1, FromDistance = $2, ToDistance = $3, Status = $4 WHERE id = $5 RETURNING *`,
            [updatedFare.Fare, updatedFare.FromDistance, updatedFare.ToDistance, updatedFare.Status, id]
        );
        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

async function checkDuplicateFare(newFare) {
    try {
        const result = await sql.query(
            `SELECT COUNT(*) FROM ${this.schema}.Fare_Master WHERE Fare = $1 AND FromDistance = $2 AND ToDistance = $3`,
            [newFare.Fare, newFare.FromDistance, newFare.ToDistance]
        );

        return parseInt(result.rows[0].count) > 0;
    } catch (error) {
        throw error;
    }
}

module.exports = {
    insertFare,
    getAllFares,
    getFareById,
    deleteFare,
    updateFare,
    checkDuplicateFare,
    init
};
