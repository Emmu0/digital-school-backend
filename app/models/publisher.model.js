const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function findAll() {
  try {
    const result = await sql.query(`SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.publisher`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}


async function createPublisher(newPublisher, userid) {
  delete newPublisher.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.publisher(name, status, createdbyid, lastmodifiedbyid  ) VALUES ($1,$2,$3,$4) RETURNING *`,
    [
      newPublisher.name,
      newPublisher.status,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function findByPublisherId(id) {
  const result = await sql.query(
    `SELECT * FROM ${this.schema}.publisher WHERE id = $1`,
    [id]
  );
  if (result.rows.length > 0) return result.rows;
  return null;
}


async function updateById(id, newPublisher, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.publisher SET name = $1, status = $2, lastmodifiedbyid = $3 WHERE id = $4 RETURNING *`,
      [
        newPublisher.name,
        newPublisher.status,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { id, ...newPublisher };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteById(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.publisher WHERE id = $1`, [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};


module.exports = { findAll, createPublisher, findByPublisherId, updateById, deleteById, init };
