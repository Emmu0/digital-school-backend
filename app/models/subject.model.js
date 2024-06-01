/**
 * @author: Abdul Pathan
 */

const { stat } = require("fs");
const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}

//Add by Aamir khan 14-05-2024
async function fetchActiveRecords(){
 
  try {
    let query = `SELECT * FROM ${this.schema}.subject sub WHERE sub.status = 'Active'`;

    const result = await sql.query(query);
    console.log('resultData==>',result);
    if (result.rows.length > 0)
    {
      return result.rows;
    }
    else{
      return null;
    }
        

   

   
  } catch (error) {
    console.log('AkActive RecordError==>',error);
    // Handle the error
    console.error("Error executing query:", error);
  }

}

//==========================   Add By Aamir khan fetch all records  Code Start ===============================

// Add by Aamir khan
async function fetchAllRecords(status,type) {

  let query = `SELECT * FROM ${this.schema}.subject sub `;

   //   query = `SELECT * FROM ${this.schema}.subject sub WHERE sub.status = 'Active'`;

 

  if (status && status !='undefined') {
    console.log('If Status',status);
    query += `WHERE sub.status = '${status}' `
  }
  if (type != 'undefined' && type != null){
    if(status && status !='undefined'){
      query += ` AND sub.type = '${type}' `
    }else{
      query += `WHERE sub.type = '${type}' `
    }
  }
  

  const result = await sql.query(query);
  console.log('Result Data Rows -->', result.rows);
  return result.rows;
}






//==========================   Aamir khan fetch all records  Code End ===============================
// Added By Pathan || fetch all records
//==========================   Add By Aamir khan fetch all records  Code Start ===============================

// async function fetchAllRecords(status, type) {
//   let query = `SELECT * FROM ${this.schema}.subject sub `;
//   if (status && status != 'undefined') {
//     query += `WHERE sub.status = '${status}' `
//   }
//   if (type != 'undefined' && type != null) {
//     if (status && status != 'undefined') {
//       query += ` AND sub.type = '${type}' `
//     } else {
//       query += `WHERE sub.type = '${type}' `
//     }
//   }
//   const result = await sql.query(query);

//   return result.rows;
// }

//==========================   Aamir khan fetch all records  Code End ===============================


// Added By Pathan || fetch record by id
async function fetchRecordById(id) {
  let query = `SELECT * FROM ${this.schema}.subject sub`;

  const result = await sql.query(query + ` WHERE sub.id = $1`, [id]);
  if (result.rows.length > 0)
    return result.rows[0];
  return null;
};

// Added By Pathan || add records
//Add By Aamir khan shortname Field
async function addRecord(newSubject, userid) {
  const result = await sql.query(`INSERT INTO ${this.schema}.subject (name,status,shortname, type,  createdbyid, lastmodifiedbyid )  VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
    [newSubject.name, newSubject.status, newSubject.shortname, newSubject.type, userid, userid]);
  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...newSubject };
  }
  return null;
};

// Added By Pathan || update record by id
async function updateRecordById(id, newSubject) {
  const query = buildUpdateQuery(id, newSubject, this.schema);

  var colValues = Object.keys(newSubject).map(function (key) {
    return newSubject[key];
  });
  const result = await sql.query(query, colValues);

  if (result.rowCount > 0) {
    return { "id": id, ...newSubject };
  }
  return null;
};

function buildUpdateQuery(id, cols, schema) {
  var query = [`UPDATE ${schema}.subject`];
  query.push('SET');
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));
  query.push('WHERE id = \'' + id + '\'');
  return query.join(' ');
}

// Added By Pathan || delete record by id
async function deleteRecord(id) {
  try {
    const result = await sql.query(`DELETE FROM ${this.schema}.subject WHERE id = $1`, [id]);

    if (result.rowCount > 0)
      return "Success"
  }
  catch (error) {
    return null;
  }
};


// Added By Pathan || check duplicate Record
async function duplicateRecord(id, request) {


  let query = `SELECT id, name FROM ${this.schema}.subject `

  if (id) {
    query += ` WHERE id != '${id}' AND name = '${request.name}' AND type = '${request.type}' `;

  } else if (request.name) {
    query += ` WHERE name = '${request.name}'`;   // Add by Aamir khan 10-05-2024
  }
  console.log('queryCheck==>',query);
  const result = await sql.query(query);


  if (result.rows && result.rows.length > 0) {

    return result.rows[0];
  }

  return null;
}


module.exports = {fetchActiveRecords,fetchAllRecords, fetchRecordById, addRecord, updateRecordById, deleteRecord, duplicateRecord, init };