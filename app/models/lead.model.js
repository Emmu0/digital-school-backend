const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
async function create(newLead, userid) {

  delete newLead.id;
  const status = 'Not Registered'
  const result =
    await sql.query(`INSERT INTO ${this.schema}.lead (firstname, lastname, status, class_id, religion, dateofbirth, gender, email,adharnumber, phone, pincode, street, city, state, country, description,father_name,mother_name,father_qualification,mother_qualification,father_occupation,mother_occupation,createdbyid,lastmodifiedbyid)VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24) RETURNING *`,
      [newLead.firstname, newLead.lastname, status, newLead.class_id, newLead.religion, newLead.dateofbirth, newLead.gender, newLead.email, newLead.adharnumber, newLead.phone, newLead.pincode, newLead.street, newLead.city, newLead.state, newLead.country, newLead.description, newLead.father_name, newLead.mother_name,
      newLead.father_qualification, newLead.mother_qualification, newLead.father_occupation, newLead.mother_occupation, userid, userid]);
  console.log('result.rows.length====???', result.rows);
  if (result.rows.length > 0) {
    // return { id: result.rows[0].id, ...newLead };
    return { id: result.rows[0].id, ...result.rows[0] };
  }
  return null;
};

async function findById(id) {
  let query = `SELECT * FROM ${this.schema}.lead`;
  const result = await sql.query(query + ` WHERE lead.id = $1`, [id]);

  if (result.rows.length > 0) {
    return result.rows[0];
  }
  return null;
};

async function findAll() {

  let query = `SELECT ld.*, cls.classname as classname FROM ${this.schema}.lead ld
  LEFT JOIN ${this.schema}.class cls ON cls.id = ld.class_id`;
  const result = await sql.query(query);
  if (result) {

  }
  return result.rows;
};


async function updateById(id, newLead, userid) {
  console.log('efoppcjdwuhfuhfrbhu===========>', id, newLead, userid);
  delete newLead.id;
  newLead['lastmodifiedbyid'] = userid;
  const query = buildUpdateQuery(id, newLead, this.schema);


  var colValues = Object.keys(newLead).map(function (key) {

    return newLead[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { "id": id, ...newLead };
  }
  return null;
};


async function deleteLead(id) {
  console.log('deleteLead========??????', id);
  const result = await sql.query(`DELETE FROM ${this.schema}.lead WHERE id = $1`, [id]);

  if (result.rowCount > 0)
    return "Success"
  return null;
};



function buildUpdateQuery(id, cols, schema) {


  var query = [`UPDATE ${schema}.lead`];
  query.push('SET');


  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));


  query.push('WHERE id = \'' + id + '\'');


  return query.join(' ');
}


async function duplicateRecord(id, req) {
  let query = `SELECT * FROM ${this.schema}.lead `

  if (id) {
    query += ` WHERE id != '${id}' `;
  }
  else {

  }
  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  } else {
    return null;
  }
}
module.exports = { findById, updateById, findAll, create, deleteLead, duplicateRecord, init };