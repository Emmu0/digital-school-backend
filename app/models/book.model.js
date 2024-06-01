const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function findAll() {
  try {
    const result = await sql.query(`SELECT * FROM ${this.schema}.v_book`);
    return result.rows;
  } catch (error) {
    throw error;
  }
}

async function createBook(newBook, userid) {
  console.log('newBook', newBook)
  delete newBook.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.book(title, author_id, isbn, category_id, publisher_id, publish_date, status, language_id, createdbyid, lastmodifiedbyid) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10) RETURNING *`,
    [
      newBook.title,
      newBook.author_id,
      newBook.isbn,
      newBook.category_id,
      newBook.publisher_id,
      newBook?.publish_date,
      newBook.status,
      newBook.language_id,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function findByBookId(id) {
  const result = await sql.query(
    `SELECT * FROM ${this.schema}.v_book WHERE id = $1`,
    [id]
  );
  if (result.rows.length > 0) return result.rows[0];
  return null;
}

async function updateById(id, newBook, userid) {
  try {
    const result = await sql.query(
      `UPDATE ${this.schema}.book SET title = $1, author_id = $2, isbn = $3, category_id = $4, publisher_id = $5, publish_date = $6, status = $7, language_id = $8, lastmodifiedbyid = $9 WHERE id = $10 RETURNING *`,
      [
        newBook.title,
        newBook.author_id,
        newBook.isbn,
        newBook.category_id,
        newBook.publisher_id,
        newBook.publish_date,
        newBook.status,
        newBook.language_id,
        userid,
        id,
      ]
    );

    if (result.rows.length > 0) {
      return { "id": id, ...newBook };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteById(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.book WHERE id = $1`, [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};

async function findBylanguageId(language_id) {
  const result = await sql.query(
    `SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.v_book WHERE language_id = $1`,
    [language_id]
  );
  return result.rows;
}

async function findByCategoryId(category_id) {
  const result = await sql.query(
    `SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.v_book WHERE category_id = $1`,
    [category_id]
  );
  return result.rows;
}

async function findByPublisherId(publisher_id) {
  const result = await sql.query(
    `SELECT ROW_NUMBER() Over (ORDER BY (SELECT NULL)) As serial, * FROM ${this.schema}.v_book WHERE publisher_id = $1`,
    [publisher_id]
  );
  return result.rows;
}

module.exports = { findAll, createBook, findByBookId, updateById, deleteById, findBylanguageId, findByCategoryId, findByPublisherId, init };
