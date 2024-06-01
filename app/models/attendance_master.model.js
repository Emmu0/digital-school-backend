/**
 * @author: Abdul Pathan
 */

const sql = require("./db.js");

let schema = '';
function init(schema_name) {
    this.schema = schema_name;
}
//fetch All Records
async function getAllRecords() {  
    let query = `SELECT
                    am.id,
                    am.class_id,
                    am.section_id,
                    am.session_id,
                    am.total_lectures,
                    am.type,
                    am.month,
                    am.year,
                    concat(cls.classname,' [', cls.aliasname, ']') AS class_name,
                    sec.name As section_name
                FROM ${this.schema}.attendance_master am
                INNER JOIN ${this.schema}.class cls ON cls.id = am.class_id
                INNER JOIN ${this.schema}.section sec ON sec.id = am.section_id `

    const result = await sql.query(query);
    if (result.rows.length > 0)
        return result.rows;

    return null;
};

//fetch Record By Id
async function getRecordById(id) {
    let query = `SELECT * FROM ${this.schema}.attendance_master `

    const result = await sql.query(query + ` WHERE id = $1`, [id]);
    if (result.rows.length > 0)
        return result.rows[0];

    return null;
}


//check duplicate Record
async function duplicateRecord(id, req) {

    let query = `SELECT id, class_id, section_id, month, year FROM ${this.schema}.attendance_master `

    if (id) {
        query += ` WHERE id != '${id}' AND class_id = '${req.class_id}' AND section_id = '${req.section_id}' AND month = '${req.month}' AND year = '${req.year}' `;
    }
    else {
        query += ` WHERE class_id = '${req.class_id}' AND section_id = '${req.section_id}' AND month = '${req.month}' AND year = '${req.year}' `;
    }

    const result = await sql.query(query);
    if (result.rows.length > 0) {
        return result.rows;
    }

    return null;
}

//add Record
async function addRecord(req, userid) {
    const result = await sql.query(`INSERT INTO ${this.schema}.attendance_master (class_id, section_id, total_lectures, type, month, year, createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
        [req.class_id, req.section_id, req.total_lectures, req.type, req.month, req.year, userid, userid]);

    if (result.rows.length > 0) {
        return { id: result.rows[0].id, ...req };
    }
    return null;
}


//update Record
async function updateRecordById(id, records, userid) {

    records['lastmodifiedbyid'] = userid;

    const query = buildUpdateQuery(id, records, this.schema);
    var colValues = Object.keys(records).map(function (key) {
        return records[key];
    });
    const result = await sql.query(query, colValues);
    if (result.rowCount > 0) {
        return { "id": id, ...records };
    }
    return null;
};

function buildUpdateQuery(id, cols, schema) {

    var query = [`UPDATE ${schema}.attendance_master`];
    query.push('SET');
    var set = [];
    Object.keys(cols).forEach(function (key, i) {
        set.push(key + ' = ($' + (i + 1) + ')');
    });
    query.push(set.join(', '));
    query.push('WHERE id = \'' + id + '\'');
    return query.join(' ');
}

module.exports = { init, getAllRecords, getRecordById, duplicateRecord, addRecord, updateRecordById };
