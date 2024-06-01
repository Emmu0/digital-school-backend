const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function findAll() {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.category`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}


async function createCategory(newCategory, userid) {
  delete newCategory.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.category(name, description, createdbyid, lastmodifiedbyid  ) VALUES ($1,$2,$3,$4) RETURNING *`,
    [
      newCategory.name,
      newCategory.description,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function findByCategoryId(id) {
  const result = await sql.query(
    `SELECT * FROM ${this.schema}.category WHERE id = $1`,
    [id]
  );
  if (result.rows.length > 0) return result.rows;
  return null;
}


async function updateById(id, newCategory, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.category SET name = $1, description = $2, lastmodifiedbyid = $3 WHERE id = $4 RETURNING *`,
      [
        newCategory.name,
        newCategory.description,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { "id": id, ...newCategory };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteById(id){
    const result = await sql.query(`DELETE FROM ${this.schema}.category WHERE id = $1`, [id]);
    if(result.rowCount > 0)
      return "Success"
    return null;
  };

  
module.exports = { findAll, createCategory, findByCategoryId, updateById, deleteById, init };
