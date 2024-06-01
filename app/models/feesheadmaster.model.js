/**
 * @author: Pooja Vaishnav
 */

const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}
//fetch All Records
async function getAllRecords(name) {
  let query = `SELECT * FROM ${this.schema}.fee_head_master ORDER BY order_no`;
  console.log("query==>", query);
  const result = await sql.query(query);
  console.log("result@@@=>", result);
  if (result.rows.length > 0) return result.rows;

  return null;
}

//fetch All Records
async function getAllRecordsByStatus(status) {
  let query = `SELECT * FROM ${this.schema}.fee_head_master fh `;
  query += ` WHERE status = '${status}' `;
  console.log("query==>", query);
  const result = await sql.query(query);
  console.log("result@@@=>", result);
  if (result.rows.length > 0) return result.rows;

  return null;
}

//fetch Record By Id
async function getRecordById(id) {
  try {
    if (id) {
      const query = `SELECT * FROM ${this.schema}.fee_head_master WHERE id = $1`;
      console.log("query while get by id-->", query);

      const result = await sql.query(query, [id]);

      if (result.rows.length > 0) {
        return result.rows;
      }
    }
  } catch (error) {
    // Handle the error appropriately, e.g., log or throw
    console.error("Error in getRecordById:", error);
    throw error;
  }
}

//check duplicate Record
async function duplicateRecord(id, request) {
  let query = `SELECT id,name FROM ${this.schema}.fee_head_master `;

  if (request.classname) {
    query += ` WHERE name = '${request.name}' `;

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
  const result = await sql.query(
    `INSERT INTO ${this.schema}.fee_head_master (name, status, createdbyid, lastmodifiedbyid,order_no )  VALUES ($1, $2, $3, $4, $5) RETURNING *`,
    [request.name, request.status, userid, userid, request.order_no]
  );

  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...request };
  }
  return null;
}

//delete Record
async function deleteRecord(id) {
  const result = await sql.query(
    `DELETE FROM ${this.schema}.fee_head_master WHERE id = $1`,
    [id]
  );

  if (result.rowCount > 0) return "Success";
  return null;
}

//update Record
async function updateRecordById(id, classRecord, userid) {
  classRecord["lastmodifiedbyid"] = userid;
  const query = buildUpdateQuery(id, classRecord, this.schema);

  var colValues = Object.keys(classRecord).map(function (key) {
    return classRecord[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { id: id, ...classRecord };
  }
  return null;
}

function buildUpdateQuery(id, cols, tenateCode) {
  var query = [`UPDATE ${tenateCode}.fee_head_master`];
  query.push("SET");
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + " = ($" + (i + 1) + ")");
  });
  query.push(set.join(", "));
  query.push("WHERE id = '" + id + "'");
  return query.join(" ");
}

module.exports = {
  init,
  getAllRecords,
  getRecordById,
  getAllRecordsByStatus,
  duplicateRecord,
  addRecord,
  deleteRecord,
  updateRecordById,
};
