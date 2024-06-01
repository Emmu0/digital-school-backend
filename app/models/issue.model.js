const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function findAll() {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.v_issue`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}


async function createIssue(newIssue, userid) {
  delete newIssue.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.issue(book_id, parent_type, parent_id, checkout_date, due_date, status, remark, createdbyid, lastmodifiedbyid) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
    [
      newIssue.book_id,
      newIssue.parent_type,
      newIssue.parent_id,
      newIssue.checkout_date,
      newIssue.due_date,
      newIssue.status,
      newIssue.remark,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function findByBookId(book_id) {
  const result = await sql.query(
    `SELECT * FROM ${this.schema}.v_issue WHERE book_id = $1`,
    [book_id]
  );
  return result.rows;
}

async function  findByIssueId(id) {
  const result = await sql.query(
    `SELECT * FROM ${this.schema}.v_issue WHERE id = $1`,
    [id]
  );
  if (result.rows.length > 0) return result.rows[0];
  return null;
}


async function updateById(id, newIssue, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.issue SET book_id = $1, parent_type = $2, parent_id = $3, checkout_date = $4, due_date = $5, return_date = $6, status = $7, remark = $8, lastmodifiedbyid = $9 WHERE id = $10 RETURNING *`,
      [
        newIssue.book_id,
        newIssue.parent_type,
        newIssue.parent_id,
        newIssue.checkout_date,
        newIssue.due_date,
        newIssue.return_date,
        newIssue.status,
        newIssue.remark,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { "id": id, ...newIssue };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteById(id){
    const result = await sql.query(`DELETE FROM ${this.schema}.issue WHERE id = $1`, [id]);
    if(result.rowCount > 0)
      return "Success"
    return null;
  };

  
module.exports = { findAll, createIssue, findByIssueId, findByBookId, updateById, deleteById, init };
