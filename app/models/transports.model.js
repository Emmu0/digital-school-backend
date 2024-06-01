// /*
//     Author      :   shivam shrivastava
//     Date        :   Date
//     ModuleName  :   event.model.js
//     Module      :   This module handles events in the application.
// */

// // transport.model.js


const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}


async function CheckDuplicateTransport(isUpdate, body) {
    let query = `SELECT id, driver_id, vehicle_no, type, seating_capacity, status, end_point FROM ${this.schema}.transport`;

    query += body.vehicle_no ? ` WHERE vehicle_no = '${body.vehicle_no}'` : '';
    query += body.type ? ` AND type = '${body.type}'` : '';
    query += body.driver_id ? ` AND driver_id = '${body.driver_id}'` : '';
    query += body.end_point ? ` AND end_point = '${body.end_point}'` : '';
    query += body.status ? ` AND status = '${body.status}'` : '';

    const result = await sql.query(query);
    console.log('result=======>', result.rows);

    return (!isUpdate && result.rows.length > 0) || (isUpdate &&
        result.rows.length > 0 &&
        (result.rows[0]?.seating_capacity == body?.seating_capacity &&
            (result.rows[0]?.driver_id == body.driver_id ||
                result.rows[0]?.end_point == body.end_point) ||
            (result.rows[0]?.driver_id == body.driver_id &&
                result.rows[0]?.end_point == body.end_point)))
        ? result.rows
        : null;
}

async function createTransport(transportData) {
    try {
        const result = await sql.query(
            `INSERT INTO ${this.schema}.Transport (driver_id, vehicle_no, type, seating_capacity, status, end_point) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
            [
                transportData.driver_id,
                transportData.vehicle_no,
                transportData.type,
                transportData.seating_capacity,
                transportData.status,
                transportData.end_point,
            ]
        );

        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

async function updateTransport(id, transportData) {
    try {
        const result = await sql.query(
            `UPDATE ${this.schema}.Transport SET driver_id = $1, vehicle_no = $2, type = $3, seating_capacity = $4, status = $5, end_point = $6 WHERE id = $7 RETURNING *`,
            [
                transportData.driver_id,
                transportData.vehicle_no,
                transportData.type,
                transportData.seating_capacity,
                transportData.status,
                transportData.end_point,
                id,
            ]
        );

        if (result.rows.length === 1) {
            return result.rows[0];
        } else {
            return null;
        }
    } catch (error) {
        throw error;
    }
}



async function getAllTransports() {
    try {
        const result = await sql.query(`SELECT t.*, CONCAT(c.firstname, ' ', c.lastname) AS driver_name, l.location AS location_name FROM ${this.schema}.transport AS t LEFT JOIN ${this.schema}.contact AS c ON t.driver_id = c.id LEFT JOIN ${this.schema}.location_master AS l ON t.end_point = l.id`);
        return result.rows;
    } catch (error) {
        throw error;
    }
}

async function getTransportById(id) {
    try {
        const result = await sql.query(`SELECT t.*, CONCAT(c.firstname, ' ', c.lastname) AS driver_name, c.phone AS driver_phone, l.location AS location_name FROM ${this.schema}.transport AS t LEFT JOIN ${this.schema}.contact AS c ON t.driver_id = c.id LEFT JOIN ${this.schema}.location_master AS l ON t.end_point = l.id WHERE t.id = $1;`, [id]);
        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}

async function deleteTransport(id) {
    try {
        const result = await sql.query(
            `DELETE FROM ${this.schema}.Transport WHERE id = $1 RETURNING *`,
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
// This is Using to Fetch transportation vehicles Records
async function findAllVehicles(title) {
    let query = `SELECT trans.*, concat(con.firstname, ' ' , con.lastname) drivername, con.id driverid FROM ${this.schema}.transport trans `;
    query += ` INNER JOIN ${this.schema}.contact con ON con.Id = trans.driver_id `;



    const result = await sql.query(query);
    return result.rows;
}
module.exports = {
    createTransport,
    updateTransport,
    getAllTransports,
    getTransportById,
    deleteTransport,
    findAllVehicles,
    CheckDuplicateTransport,
    init
};
