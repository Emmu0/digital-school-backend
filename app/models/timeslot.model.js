/**
 * @author : Pooja Vaishnav
 */

const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
async function fetchAllRecords(title) {
  let query = `SELECT * FROM ${this.schema}.time_slot sub`;
  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
};

// Added By Pathan || fetch record by id
async function fetchRecordById(id) {
  let query = `SELECT * FROM ${this.schema}.time_slot tim`;

  const result = await sql.query(query + ` WHERE tim.id = $1`, [id]);
  if (result.rows.length > 0)
    return result.rows[0];
  return null;
};

// Added By Pathan || add records
async function addRecord(newSubject, userid) {
  const result = await sql.query(`INSERT INTO ${this.schema}.time_slot (type,start_time,end_time,status,session_id,createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4, $5, $6,$7) RETURNING *`,
    [newSubject.type, newSubject.start_time, newSubject.end_time, newSubject.status, newSubject.session_id, userid, userid]);
  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...newSubject };
  }
  return null;
};

// Added By Pathan || update record by id
async function updateRecordById(id, newTimeSlot, userid) {
  newTimeSlot['lastmodifiedbyid'] = userid;

  const query = buildUpdateQuery(id, newTimeSlot, this.schema);
  var colValues = Object.keys(newTimeSlot).map(function (key) {
    return newTimeSlot[key];
  });
  const result = await sql.query(query, colValues);

  if (result.rowCount > 0) {
    return { "id": id, ...newTimeSlot };
  }
  return null;
};

function buildUpdateQuery(id, cols, schema) {

  var query = [`UPDATE ${schema}.time_slot`];
  query.push('SET');
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));
  query.push('WHERE id = \'' + id + '\'');
  return query.join(' ');
}

// Added By Pathan || delete record by id
async function deleteRecord(id) {
  try {
    const result = await sql.query(`DELETE FROM ${this.schema}.time_slot WHERE id = $1`, [id]);

    if (result.rowCount > 0)
      return "Success"
  }
  catch (error) {
    return null;
  }
};


// Added By Pathan || check duplicate Record
async function duplicateRecord(id, request) {

  let query = `SELECT id, type,start_time,end_time,status,session_id FROM ${this.schema}.time_slot `

  if (id) {
    query += ` WHERE id != '${id}' AND type = '${request.type}' AND start_time = '${request.start_time}' AND end_time = '${request.end_time}' AND status = '${request.status}' AND session_id = '${request.session_id}' `;

  }
  else {
    query += ` WHERE type = '${request.type}' AND start_time = '${request.start_time}' AND end_time = '${request.end_time}' AND status = '${request.status}'  AND session_id = '${request.session_id}' `;
  }

  const result = await sql.query(query);

  if (result.rows.length > 0) {
    return result.rows[0];
  }
  return null;
}


module.exports = { fetchAllRecords, fetchRecordById, addRecord, updateRecordById, deleteRecord, duplicateRecord, init };