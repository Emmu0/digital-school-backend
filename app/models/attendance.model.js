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
                    at.id, 
                    at.student_id, 
                    at.attendance_master_id, 
                    at.present, 
                    at.absent, 
                    concat(st.firstname ,' ' ,st.lastname) student_name,
                    am.class_id, 
                    am.section_id, 
                    am.type,
                    am.session_id,
                    cls.classname, 
                    concat(cls.classname ,' ' ,cls.aliasname) class_name,
                    sec.name section_name
                FROM ${this.schema}.attendance at
                INNER JOIN ${this.schema}.attendance_master am ON am.id = at.attendance_master_id
                INNER JOIN ${this.schema}.student st ON st.id = at.student_id
                INNER JOIN ${this.schema}.class cls ON cls.id = am.class_id
                INNER JOIN ${this.schema}.section sec  ON sec.id = am.section_id `

  const result = await sql.query(query);

  if (result.rows.length > 0) {

    return result.rows;
  }

  return null;
};


async function getAttendanceByStudentId(student_id) {

  let query = `SELECT at.*, CONCAT(st.firstname, ' ', st.lastname) AS student_name,
              CONCAT(cls.classname, ' ', cls.aliasname) AS class_name, sec.name AS section_name,
              am.class_id, am.section_id,am.month
              FROM ${this.schema}.attendance AS at
              INNER JOIN ${this.schema}.student AS st ON st.id = at.student_id
              INNER JOIN ${this.schema}.attendance_master AS am ON am.id = at.attendance_master_id
              INNER JOIN ${this.schema}.class AS cls ON cls.id = am.class_id
              INNER JOIN ${this.schema}.section AS sec ON sec.id = am.section_id`;

  let params = [];

  if (student_id != null) {
    query += ' WHERE at.student_id = $1';
    params.push(student_id);
  }


  const result = await sql.query(query, params);
  if (result.rows.length > 0)
    return result.rows;

  return null;
}
/*Fetch according to the month and year */
async function getRecordsByMonthAndYear(month, year) {

  let query = `SELECT 
  at.id, 
  at.student_id, 
  at.attendance_master_id, 
  at.present, 
  at.absent, 
  CONCAT(st.firstname, ' ', st.lastname) AS student_name,
  am.class_id, 
  am.section_id, 
  am.type,
  am.session_id,
  am.month,
  am.year,
  cls.classname, 
  CONCAT(cls.classname, ' ', cls.aliasname) AS class_name,
  sec.name AS section_name
FROM ${this.schema}.attendance at
INNER JOIN ${this.schema}.attendance_master am 
  ON am.id = at.attendance_master_id
INNER JOIN ${this.schema}.student st 
  ON st.id = at.student_id
INNER JOIN ${this.schema}.class cls 
  ON cls.id = am.class_id
INNER JOIN ${this.schema}.section sec 
  ON sec.id = am.section_id`;

  query += (month && year) ? ` WHERE am.month = '${month}' AND am.year = '${year}' ` : '';

  const result = await sql.query(query);
  if (result.rows.length > 0)

    return result.rows;

  return null;
}

//fetch Record By Id
async function getRecordById(id) {
  let query = `SELECT * FROM ${this.schema}.attendance `

  const result = await sql.query(query + ` WHERE id = $1`, [id]);
  if (result.rows.length > 0)
    return result.rows[0];

  return null;
}

// Add Record
async function addRecord(request, userid) {

  if (!Array.isArray(request)) {
    const result = await sql.query(`INSERT INTO ${this.schema}.attendance (attendance_master_id, student_id, present,absent,createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4,$5,$6) RETURNING *`,
      [request.attendance_master_id, request.student_id, request.present, request.absent, userid, userid]);

    if (result.rows.length > 0) {
      return { id: result.rows[0].id, ...request };
    }
  } else {
    const insertResults = [];
    for (const obj of request) {
      const result = await sql.query(`INSERT INTO ${this.schema}.attendance (attendance_master_id, student_id, present, absent, createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
        [obj.attendance_master_id, obj.student_id, obj.present, obj.absent, userid, userid]);

      if (result.rows.length > 0) {
        insertResults.push({ id: result.rows[0].id, ...obj });
      }
    }

    return insertResults.length > 0 ? insertResults : null;
  }

  return null;
}

//check duplicate Record
async function duplicateRecord(req) {

  let query = `SELECT id, attendance_master_id, student_id FROM ${this.schema}.attendance `


  if (req.length > 0 && 'attendance_master_id' in req[0]) {

    query += ` WHERE attendance_master_id = '${req[0].attendance_master_id}'  `;

  }

  const result = await sql.query(query);
  if (result.rows.length > 0) {

    return result.rows[0];
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
  var query = [`UPDATE ${schema}.attendance`];
  query.push('SET');
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));
  query.push('WHERE id = \'' + id + '\'');
  return query.join(' ');
}
module.exports = { init, getAttendanceByStudentId, getAllRecords, getRecordById, addRecord, duplicateRecord, updateRecordById, getRecordsByMonthAndYear };


