const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
//.................................................create.....................................
async function create(newFile, userid) {
  delete newFile.id;
  const result = await sql.query(`INSERT INTO ${this.schema}.file ( title, filetype, filesize, description, parentid, createdbyid, lastmodifiedbyid)  VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
    [newFile.title, newFile.filetype, newFile.filesize, newFile.description, newFile.parentid, userid, userid]);
  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...newFile };
  }

  return null;
}


//.............................................find By Id....................................

async function findById(id) {

  let query = `SELECT fl.*, `;
  query += ` concat(cu.firstname, ' ' , cu.lastname) createdbyname,`;
  query += ` concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname  `;
  query += ` FROM ${this.schema}.file fl `;
  query += ` INNER JOIN public.user cu ON cu.Id = fl.createdbyid `;
  query += ` INNER JOIN public.user mu ON mu.Id = fl.lastmodifiedbyid `;
  const result = await sql.query(query + 'WHERE fl.id = $1', [id]);

  if (result.rows.length > 0)
    return result.rows[0];

  return null;
};


//.............................................find By PrentId.................................

async function findByParentId(id) {

  let query = `SELECT fl.*, `;
  query += ` concat(cu.firstname, ' ' , cu.lastname) createdbyname,  `;
  query += ` concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname  `;
  query += ` FROM ${this.schema}.file fl `;
  query += ` INNER JOIN public.user cu ON cu.Id = fl.createdbyid `;
  query += ` INNER JOIN public.user mu ON mu.Id = fl.lastmodifiedbyid `;
  const result = await sql.query(query + 'WHERE fl.parentid = $1', [id]);

  if (result.rows.length > 0)

    return result.rows;

  return null;
};

//.............................................fetch all file.................................

async function findAll(title) {


  let query = `SELECT fl.*, `;
  query += ` concat(cu.firstname, ' ' , cu.lastname) createdbyname,  `;
  query += ` concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname  `;
  query += ` FROM ${this.schema}.file fl `;
  query += ` INNER JOIN public.user cu ON cu.Id = fl.createdbyid `;
  query += ` INNER JOIN public.user mu ON mu.Id = fl.lastmodifiedbyid `;

  const result = await sql.query(query);
  return result.rows;


};



//.............................................Update file.................................

async function updateById(id, newFile) {
  delete newFile.id;
  const query = buildUpdateQuery(id, newFile);

  var colValues = Object.keys(newFile).map(function (key) {
    return newFile[key];
  });

  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { "id": id, ...newFile };
  }
  return null;



};


//.............................................delete file by Id.................................


async function deleteFile(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.file WHERE id = $1`, [id]);

  if (result.rowCount > 0)
    return "Success"
  return null;
};



function buildUpdateQuery(id, cols) {

  var query = [`UPDATE ${this.schema}.file`];
  query.push('SET');

  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));

  query.push('WHERE id = \'' + id + '\'');

  return query.join(' ');
}

module.exports = { findById, findByParentId, create, updateById, deleteFile, findAll, init };