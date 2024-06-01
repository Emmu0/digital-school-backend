/**
 * @author: Abdul Pathan
 */

const sql = require("./db.js");

let schema = '';
function init(schema_name){
    this.schema = schema_name;
}
//All Records
async function getRecords(classId) {
    let query = `SELECT 
                    sca.id, 
                    sca.subject_id, 
                    sca.class_id,
                    sub.name AS subjectname,
                    sub.category,
                    sub.type,
                    sub.shortname,
                    cls.classname
                FROM ${this.schema}.assign_subject AS sca
                INNER JOIN ${this.schema}.subject AS sub ON sub.id = sca.subject_id
                INNER JOIN ${this.schema}.class AS cls ON cls.id = sca.class_id `;

    if (classId) {
        query += `  WHERE sca.class_id = '${classId}' `;
    }

    const result = await sql.query(query);
    if (result.rows.length > 0)
        return result.rows;

    return null
};


//add Record
async function addRecord(request, userid) {
    const result = await sql.query(`INSERT INTO ${this.schema}.assign_subject (class_id, subject_id, createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4) RETURNING *`,
        [request.class_id, request.subject_id, userid, userid]);
    if (result.rows.length > 0) {
        return { id: result.rows[0].id, ...request };
    }
    return null;
};

//All Duplicated class
async function duplicateRecord(id, req) {

    let query = `SELECT id, subject_id, class_id FROM ${this.schema}.assign_subject `;
    if (id) {
        query += `  WHERE id != '${id}' AND class_id = '${req.class_id}' AND subject_id = '${req.subject_id}'`;
    } else {
        query += `  WHERE class_id = '${req.class_id}' AND subject_id = '${req.subject_id}'`;
    }

    const result = await sql.query(query);
    if (result.rows.length > 0) {
        return result.rows;
    }

    return null;
};

//delete Record
async function deleteRecord(id) {
    const result = await sql.query(`DELETE FROM ${this.schema}.assign_subject WHERE id = $1`, [id]);
    if (result.rowCount > 0)
        return "Success"
    return null;
};

//get RecordById
async function getRecordById(id) {
    let query = `SELECT * FROM ${this.schema}.assign_subject`;
    const result = await sql.query(query + ` WHERE assign_subject.id = $1`, [id]);
    if (result.rows.length > 0)
        return result.rows[0];
    return null;
};

module.exports = { getRecords, addRecord, deleteRecord, getRecordById, duplicateRecord,init };

