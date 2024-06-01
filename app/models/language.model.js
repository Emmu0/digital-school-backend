const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function findAll() {
  try {
    const result = await sql.query(`SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.language`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}


async function createLanguage(newLanguage, userid) {
  delete newLanguage.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.language(name, description, createdbyid, lastmodifiedbyid  ) VALUES ($1,$2,$3,$4) RETURNING *`,
    [
      newLanguage.name,
      newLanguage.description,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function findByLanguageId(id) {
  const result = await sql.query(
    `SELECT * FROM ${this.schema}.language WHERE id = $1`,
    [id]
  );
  if (result.rows.length > 0) return result.rows;
  return null;
}


async function updateById(id, newLanguage, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.language SET name = $1, description = $2, lastmodifiedbyid = $3 WHERE id = $4 RETURNING *`,
      [
        newLanguage.name,
        newLanguage.description,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { "id": id, ...newLanguage };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteById(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.language WHERE id = $1`, [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};


module.exports = { findAll, createLanguage, findByLanguageId, updateById, deleteById, init };
