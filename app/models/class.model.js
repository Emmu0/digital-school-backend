/**
 * @author: Abdul Pathan
 */

const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
//fetch All Active Records
async function getAllRecordActiveRecs() {
  let query = `SELECT 
                  cls.id, 
                  concat(cls.classname,' [', cls.aliasname, ']') class_name, 
                  cls.classname, 
                  cls.aliasname, 
                  cls.status, 
                  cls.session_year
                FROM ${this.schema}.class cls `;
  query += ` WHERE status = 'active' `;

  const result = await sql.query(query);

  if (result.rows.length > 0)
    return result.rows;

  return null;
};
//fetch All Records
async function getAllRecords(name) {
  let query = `SELECT 
                  cls.id, 
                  concat(cls.classname,' [', cls.aliasname, ']') class_name, 
                  cls.classname, 
                  cls.aliasname, 
                  cls.status, 
                  cls.session_year
                FROM ${this.schema}.class cls `;

  if (name) {
    query += ` WHERE status = '${name}' `;
  }

  const result = await sql.query(query);

  if (result.rows.length > 0)
    return result.rows;

  return null;
};


//fetch Record By Id
async function getRecordById(id) {
  let query = `SELECT id, concat(cls.classname,' [', cls.aliasname, ']') classname, status FROM  ${this.schema}.class cls `
 
  if (id) {
    query += ` WHERE id = '${id}' `;
    const result = await sql.query(query);
    if (result.rows.length > 0)
      return result.rows;
  }

  return null;
}

//check duplicate Record
async function duplicateRecord(id, request) {
  let query = `SELECT id, classname FROM  ${this.schema}.class `

  if (request.classname) {
    query += ` WHERE classname = '${request.classname}' `;

    if (id) {
      query += ` AND id != '${id}'  `;
    }

    const result = await sql.query(query);
    if (result.rows.length > 0) {
      return result.rows;
    }
  }

  return null;
}

//add Record
async function addRecord(request, userid) {
  const result = await sql.query(`INSERT INTO ${this.schema}.class (classname, aliasname, status, session_year, createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
    [request.classname, request.aliasname, request.status, request.session_year, userid, userid]);


  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...request };
  }
  return null;
}

//count Record
async function getTotalRecord() {
  let query = `SELECT count(id) countTotalClass FROM ${this.schema}.class`;
  const result = await sql.query(query);

  if (result.rows.length > 0)
    return result.rows;

  return null;
};

//delete Record
async function deleteRecord(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.class WHERE id = $1`, [id]);

  if (result.rowCount > 0)
    return "Success"
  return null;
};

//update Record
async function updateRecordById(id, classRecord, userid) {
  classRecord['lastmodifiedbyid'] = userid;

  const query = buildUpdateQuery(id, classRecord, this.schema);
  var colValues = Object.keys(classRecord).map(function (key) {
    return classRecord[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { "id": id, ...classRecord };
  }
  return null;
};


function buildUpdateQuery(id, cols, schema) {
  var query = [`UPDATE ${schema}.class`];
  query.push("SET");
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + " = ($" + (i + 1) + ")");
  });
  query.push(set.join(", "));
  query.push("WHERE id = '" + id + "'");
  return query.join(" ");
}


module.exports = { init, getAllRecordActiveRecs, getAllRecords, getRecordById, duplicateRecord, addRecord, getTotalRecord, deleteRecord, updateRecordById };