const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function findAll() {
  try {
    const result = await sql.query(`SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.v_purchase`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}


async function createPurchase(newPurchase, userid) {
  delete newPurchase.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.purchase(supplier_id, book_id, quantity, date, createdbyid, lastmodifiedbyid) VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
    [
      newPurchase.supplier_id,
      newPurchase.book_id,
      newPurchase.quantity,
      newPurchase.date,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function findByPurchaseByBookId(bookId) {
  const result = await sql.query(
    `SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.v_purchase WHERE book_id = $1`,
    [bookId]
  );
  return result.rows;
}

async function findByPurchaseBysupplierId(supplierId) {
  const result = await sql.query(
    `SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.v_purchase WHERE supplier_id = $1`,
    [supplierId]
  );
  return result.rows;
}

async function updateById(id, newPurchase, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.purchase SET supplier_id = $1, book_id = $2, quantity = $3, date = $4, lastmodifiedbyid = $5 WHERE id = $6 RETURNING *`,
      [
        newPurchase.supplier_id,
        newPurchase.book_id,
        newPurchase.quantity,
        newPurchase.date,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { id, ...newPurchase };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteById(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.purchase WHERE id = $1`, [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};


module.exports = { findAll, createPurchase, findByPurchaseByBookId, updateById, deleteById, findByPurchaseBysupplierId, init };


