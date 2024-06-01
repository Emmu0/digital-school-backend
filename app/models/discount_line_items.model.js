const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}

async function create(newLineItem) {
    try {

        const query = `INSERT INTO ${this.schema}.discount_line_items (student_addmission_id, discountid) VALUES ($1, $2) RETURNING *`;
        const result = await sql.query(query, [newLineItem.student_addmission_id, newLineItem.discountid]);
        return result.rows[0];
    } catch (error) {
        throw error;
    }
}
async function fetchAllRecords() {
    let query = `select items.*, concat(st.firstname, ' ' ,st.lastname)as student_name, dis.name as discount_name
    from ${this.schema}.discount_line_items items
    Inner Join ${this.schema}.student_addmission ad on ad.id = items.student_addmission_id
    Inner Join ${this.schema}.student st on st.id = ad.studentid
    Inner Join ${this.schema}.discount dis on dis.id = items.discountid`;
    const result = await sql.query(query);
    return result.rows;
};

async function findById(studentAddmissionId) {
    try {
        const query = `select items.*, concat(st.firstname, ' ' ,st.lastname)as student_name, dis.name as discount_name,
        dis.percent as percent, dis.fee_head_id as fee_head_id
        from ${this.schema}.discount_line_items items
        Inner Join ${this.schema}.student_addmission ad on ad.id = items.student_addmission_id
        Inner Join ${this.schema}.student st on st.id = ad.studentid
        Inner Join ${this.schema}.discount dis on dis.id = items.discountid WHERE items.student_addmission_id = $1`;
        const result = await sql.query(query, [studentAddmissionId]);
        return result.rows;
    } catch (error) {
        throw error;
    }
}

async function update(lineItemId, updatedData) {
    try {
        const query = `UPDATE ${this.schema}.discount_line_items SET student_addmission_id = $1, discountid = $2 WHERE id = $3 RETURNING *`;
        const result = await sql.query(query, [updatedData.student_addmission_id, updatedData.discountid, lineItemId]);
        return result.rows[0];
    } catch (error) {
        throw error;
    }
}

async function remove(lineItemId) {
    try {
        const query = `DELETE FROM ${this.schema}.discount_line_items WHERE id = $1`;
        await sql.query(query, [lineItemId]);
        return true;
    } catch (error) {
        throw error;
    }
}

async function checkForDuplicacy(student_addmission_id, discountid) {
    try {
        const query = `SELECT * FROM ${this.schema}.discount_line_items WHERE student_addmission_id = $1 AND discountid = $2`;
        const result = await sql.query(query, [student_addmission_id, discountid]);
        return result.rows[0];
    } catch (error) {
        throw error;
    }
}

module.exports = { create, fetchAllRecords, findById, update, remove, checkForDuplicacy, init };
