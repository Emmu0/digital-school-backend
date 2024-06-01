const sql = require("./db.js");



async function create(newSubject, userid) {
  delete newSubject.id;
  const result = await sql.query("INSERT INTO subject (name, createdbyid, lastmodifiedbyid)  VALUES ($1, $2, $3) RETURNING *",
    [newSubject.name, userid, userid]);
  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...newSubject };
  }
  return null;
};

async function findById(id) {

  let query = "SELECT * FROM subject sub";


  const result = await sql.query(query + ` WHERE sub.id = $1`, [id]);
  if (result.rows.length > 0)
    return result.rows[0];

  return null;
};

async function findAll(title) {

  let query = "SELECT *  FROM subject sub";

  if (title) {
    query += ` WHERE sub.title LIKE '%${title}%'`;
  }

  const result = await sql.query(query);
  return result.rows;
};

async function updateById(id, newSubject, userid) {
  delete newSubject.id;
  newSubject['lastmodifiedbyid'] = userid;
  const query = buildUpdateQuery(id, newSubject);

  var colValues = Object.keys(newSubject).map(function (key) {
    return newSubject[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { "id": id, ...newSubject };
  }
  return null;

};


async function deletesubject(id) {
  const result = await sql.query("DELETE FROM subject WHERE id = $1", [id]);

  if (result.rowCount > 0)
    return "Success"
  return null;
};



function buildUpdateQuery(id, cols) {

  var query = ['UPDATE subject'];
  query.push('SET');


  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));


  query.push('WHERE id = \'' + id + '\'');


  return query.join(' ');
}

module.exports = { findById, updateById, findAll, create, deletesubject };
