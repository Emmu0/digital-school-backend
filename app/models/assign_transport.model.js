// assignTransport.model.js

const sql = require("./db.js");

let schema = '';

function init(schema_name) {
    this.schema = schema_name;
}


async function fetchRecordById(id) {
    try {
        let query = `SELECT * FROM ${this.schema}.assign_transport`
        if (id) {
            query += ` WHERE id = $1 OR student_addmission_id = $1`;
        }
        const result = await sql.query(query, [id]);
        if (result.rows.length > 0)
            return result.rows[0];
        return null;
    } catch (error) {
        throw new Error(`Error fetching record: ${error.message}`);
    }
}

async function addRecord(newRecord) {
    const result = await sql.query(`INSERT INTO ${this.schema}.assign_transport (student_addmission_id, transport_id, drop_location, fare_id, fare_amount, distance, route_direction, sessionid) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
        [newRecord.student_addmission_id, newRecord.transport_id, newRecord.drop_location, newRecord.fare_id, newRecord.fare_amount, newRecord.distance, newRecord.route_direction, newRecord.sessionid]);
    if (result.rows.length > 0) {
        return { id: result.rows[0].id, ...newRecord };
    }
    return null;
}

async function updateRecordById(id, newRecord) {
    const query = `UPDATE ${this.schema}.assign_transport SET student_addmission_id = $1, transport_id = $2, drop_location = $3, fare_id = $4, fare_amount = $5, distance = $6, route_direction = $7 WHERE id = $8`;
    const values = [newRecord.student_addmission_id, newRecord.transport_id, newRecord.drop_location, newRecord.fare_id, newRecord.fare_amount, newRecord.distance, newRecord.route_direction, id];
    const result = await sql.query(query, values);
    if (result.rowCount > 0) {
        return { id: id, ...newRecord };
    }
    return null;
}

async function deleteRecord(id) {
    try {
        const result = await sql.query(`DELETE FROM ${this.schema}.assign_transport WHERE id = $1`, [id]);
        if (result.rowCount > 0)
            return "Success";
    } catch (error) {
        return null;
    }
}

module.exports = {

    fetchRecordById, addRecord, updateRecordById, deleteRecord, init
};
