const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function findAll() {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.supplier`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}


async function createSupplier(newSupplier, userid) {
  delete newSupplier.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.supplier(name, contact_person, phone, email, address, status, createdbyid, lastmodifiedbyid  ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
    [
      newSupplier.name,
      newSupplier.contact_person,
      newSupplier.phone,
      newSupplier.email,
      newSupplier.address,
      newSupplier.status,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function findBySupplierId(id) {
  const result = await sql.query(
    `SELECT * FROM ${this.schema}.supplier WHERE id = $1`,
    [id]
  );
  if (result.rows.length > 0) return result.rows[0];
  return null;
}

async function updateById(id, newSupplier, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.supplier SET name = $1, contact_person = $2, phone = $3, email = $4, address = $5, status = $6, lastmodifiedbyid = $7 WHERE id = $8 RETURNING *`,
      [
        newSupplier.name,
        newSupplier.contact_person,
        newSupplier.phone,
        newSupplier.email,
        newSupplier.address,
        newSupplier.status,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { id, ...newSupplier };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteById(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.supplier WHERE id = $1`, [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};


module.exports = { findAll, createSupplier, findBySupplierId, updateById, deleteById, init };
