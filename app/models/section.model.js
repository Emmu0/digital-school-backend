/**
 * @author: Abdul Pathan
 */

const { request } = require("express");
const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}


async function getAllRecords() {
  console.log('Colling This');
  let query = `SELECT sec.id section_id, sec.name section_name,sec.strength, sec.isactive, sec.class_id,
               concat(cls.classname,' [', cls.aliasname, ']') class_name, sec.contact_id, concat(cnt.firstname, ' ' , cnt.lastname) contact_name,cls.classname class
               FROM ${this.schema}.section sec
               INNER JOIN ${this.schema}.class cls ON cls.id = sec.class_id
               LEFT JOIN  ${this.schema}.contact cnt ON cnt.id = sec.contact_id`;


  const result = await sql.query(query);
  if (result.rows.length > 0) return result.rows;

  return null;
}
// fetch All Records
async function getActiveSectionWithClass() {
  let query = `SELECT 
    cls.id as class_id,  
    cls.status, 
    sec.id as section_id,
    sec.name as section_name,
    sec.isactive,
    concat(cls.classname, ' (', sec.name, ')') as classname
  FROM ${this.schema}.section sec
  INNER JOIN ${this.schema}.class cls ON cls.id = sec.class_id
  WHERE sec.isactive = true`;


  const result = await sql.query(query);
  if (result.rows.length > 0) return result.rows;

  return null;
}
// fetch Record By Id
// async function getRecordById(id) {
//   let query = `SELECT id, name, strength, isactive, class_id, contact_id FROM ${this.schema}.section `;
//   const result = await sql.query(query + ` WHERE id = $1`, [id]);
//   if (result.rows.length > 0) return result.rows[0];

//   return null;
// }
//Change By Shahir Hussain 15-05-2024
async function getRecordById(id) {
  console.log('getRecordById===========>', id);
  let query = `SELECT 
  sec.id section_id, 
  sec.name 
  section_name,
  sec.strength, 
  sec.isactive,
  sec.class_id,
  concat(cls.classname,' [', cls.aliasname, ']') class_name, 
  sec.contact_id,
  concat(cnt.firstname, ' ' , cnt.lastname) contact_name
FROM ${this.schema}.section sec
INNER JOIN ${this.schema}.class cls ON cls.id = sec.class_id
LEFT JOIN ${this.schema}.contact cnt ON cnt.id = sec.contact_id`;
console.log('query==========------->', query);
  const result = await sql.query(query + ` WHERE sec.id = $1`, [id]);
  console.log('query result == ', result);
  if (result.rows.length > 0) {
    return result.rows[0];
  }

  return null;
}
// fetch Record By Id
async function getClassSections(classId) {
  let query = `SELECT id, name, strength, isactive, class_id FROM ${this.schema}.section WHERE isactive = true `;

  if (classId) {
    query += ` AND class_id = '${classId}' `;
  }

  const result = await sql.query(query);

  if (result.rows.length > 0) return result.rows;

  return null;
}

// Add Record
async function addRecord(request, userid) {
  const result = await sql.query(
    `INSERT INTO ${this.schema}.section (name, strength, class_id, contact_id, createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4, $5,$6) RETURNING *`,
    [
      request.name,
      request.strength,
      request.class_id,
      request.contact_id,
      userid,
      userid,
    ]
  );
  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...request };
  }
  return null;
}

//update active/inactive record
async function updateSectionActiveInactiveRecord(id, sectionRecord, userid) {

  sectionRecord["lastmodifiedbyid"] = userid;
  const query = buildUpdateQuery(id, sectionRecord, this.schema);  // Add by Aamir khan 13-05-2024
  console.log('FastCheck', query);
  var colValues = Object.keys(sectionRecord).map(function (key) {
    return sectionRecord[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { id: id, ...sectionRecord };
  }
  return null;
}

// update Record
async function updateRecordById(id, sectionRecord, userid) {
  sectionRecord["lastmodifiedbyid"] = userid;

  const query = buildUpdateQuery(id, sectionRecord,this.schema);
  var colValues = Object.keys(sectionRecord).map(function (key) {
    return sectionRecord[key];
  });

  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { id: id, ...sectionRecord };
  }
  return null;
}

// Add by Aamir khan schema  13-05-2024
function buildUpdateQuery(id, cols, schema) {


  // Setup static beginning of query
  var query = [`UPDATE ${schema}.section`];    // Add by Aamir khan schema 02-05-2024
  query.push('SET');

  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));

  query.push('WHERE id = \'' + id + '\'');

  return query.join(' ');
}

async function duplicateRecord(id, request) {
    let query = `SELECT id, name, strength, class_id, contact_id FROM ${this.schema}.section `;
    if(request.class_id){
      query += ` WHERE class_id = '${request.class_id}' AND name = '${request.name}'`;
      const result = await sql.query(query);
      console.log(result.rows,'61724501-a791-40f4-8ab9-ad908af677b9 pta karo');
      if( result.rows.length > 0){
        return result.rows
      }
    }
    // if (id) {
    //   query += ` WHERE id != '${id}' AND name = '${request.name}' AND class_id = '${request.class_id}' `;
    // } else if (request.class_id && id) {
    //   query += ` WHERE class_id = '${request.class_id}' OR id = '${id}'`;
    //   const result = await sql.query(query);
    //   console.log(result.rows,'result.rows ==> pata he');
    //     if (result.rows.length > 0) {
    //       return result.rows;
    //     }
    // }
    return null
}

module.exports = {
  init,
  getActiveSectionWithClass,
  getAllRecords,
  getRecordById,
  getClassSections,
  addRecord,
  updateRecordById,
  updateSectionActiveInactiveRecord,
  duplicateRecord,
};