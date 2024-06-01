const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function findAll() {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.author`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}


async function createAuthor(newAuthor, userid) {
  delete newAuthor.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.author(name, status, createdbyid, lastmodifiedbyid  ) VALUES ($1,$2,$3,$4) RETURNING *`,
    [
      newAuthor.name,
      newAuthor.status,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function findByAuthorId(id) {
  const result = await sql.query(
    `SELECT * FROM ${this.schema}.author WHERE id = $1`,
    [id]
  );
  if (result.rows.length > 0) return result.rows[0];
  return null;
}


async function updateById(id, newAuthor, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.author SET name = $1, status = $2, lastmodifiedbyid = $3 WHERE id = $4 RETURNING *`,
      [
        newAuthor.name,
        newAuthor.status,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { "id": id, ...newAuthor };
    }
    return null;
  } catch (error) {
    throw error;
  }
}


async function deleteById(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.author WHERE id = $1`, [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};


async function findBooksByAuthorId(id) {
  const result = await sql.query(`SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.v_book WHERE AUTHOR_ID = $1`, [id]);
  return result.rows;
}


module.exports = { findAll, createAuthor, findByAuthorId, updateById, deleteById, findBooksByAuthorId, init };
