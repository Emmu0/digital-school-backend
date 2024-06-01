const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}



{/******create contact******/ }
async function create(newContact, userid) {



  delete newContact.id;
  const result = await sql.query(`INSERT INTO ${this.schema}.contact (salutation, firstname, lastname, dateofbirth, gender,email,adharnumber,phone,profession,pincode,street,city,state,country,classid,spousename,qualification,description,parentid,department,recordtype,religion,createdbyid, lastmodifiedbyid)  VALUES ($1, $2, $3, $4, $5, $6, $7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24) RETURNING *`,
    [newContact.salutation, newContact.firstname, newContact.lastname, newContact.dateofbirth, newContact.gender, newContact.email, newContact.adharnumber, newContact.phone, newContact.profession, newContact.pincode, newContact.street, newContact.city, newContact.state, newContact.country, newContact.classid, newContact.spousename, newContact.qualification, newContact.description, newContact.parentid, newContact.department, newContact.recordtype, newContact.religion, userid, userid]);
  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...newContact };
  }
  return null;
};

{/******find a contact******/ }
async function findById(id) {
  let query = `SELECT con.*,con.id,concat(con.firstname, ' ' , con.lastname) contactname,concat(cu.firstname, ' ' , cu.lastname) createdbyname, concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname FROM ${this.schema}.contact con`;
  query += ` INNER JOIN public.user cu ON cu.Id = con.createdbyid `;
  query += ` INNER JOIN public.user mu ON mu.Id = con.lastmodifiedbyid `;
  const result = await sql.query(query + ` WHERE con.id = $1`, [id]);
  if (result.rows.length > 0)
    return result.rows[0];
  else
    return null;
};



{/******Fetch All Parent Records by Student ParentId******/ }
async function findParentByStudentParentId(id) {
  let query = `SELECT pr.* FROM ${this.schema}.contact pr`;
  const result = await sql.query(query + " WHERE pr.id = $1", [id]);
  if (result.rows.length > 0) {
    return result.rows[0];
  } else {
    return null;
  }
};

{/******Fetch All Parent Records******/ }
async function findAllParents(title) {
  let query = `SELECT con.* FROM ${this.schema}.contact con  WHERE con.recordtype = 'Parent_Father' OR  con.recordtype = 'Parent_Mother' OR  con.recordtype = 'Parent_Guardian'`;
  const result = await sql.query(query);

  return result.rows;

};

{/******Fetch All Emplyee Records******/ }
async function findAllStaffs(title) {

  let query = `SELECT con.*, concat(con.firstname, ' ' , con.lastname) staffname,con.department,con.dateofbirth,con.contactno,con.religion,con.adharnumber,con.phone,con.email,con.qualification,con.profession,con.description,con.spousename,con.gender,con.street,con.city,con.pincode,con.country, concat(cu.firstname, ' ' , cu.lastname) createdbyname, concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname FROM ${this.schema}.contact con `;
  query += ` INNER JOIN public.user cu ON cu.Id = con.createdbyid `;
  query += ` INNER JOIN public.user mu ON mu.Id = con.lastmodifiedbyid `;


  if (title) {
    query += ` WHERE con.title LIKE '%${title}%'`;
  }

  query += " AND recordtype IN ('Principal', 'Teacher', 'Admin', 'Librarian', 'Accountant', 'Driver', 'Peon', 'Security Guard', 'PTI') ";

  const result = await sql.query(query);
  return result.rows;
};

// Added by Abdul Pathan || START
async function getAllTeacherRecords() {
  let query = `SELECT id, concat(firstname, ' ' , lastname) teachername, recordtype 
              FROM ${this.schema}.contact 
              WHERE recordtype = 'Teacher' 
              order by teachername `;

  const result = await sql.query(query);

  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

/* added by Ronak Sharma */


async function findAllDrivers(title) {

  let query =
    `SELECT con.*, concat(con.firstname, ' ' , con.lastname) staffname,con.department,con.dateofbirth,con.contactno,con.religion,con.adharnumber,con.phone,con.email,con.qualification,con.profession,con.description,con.spousename,con.gender,con.street,con.city,con.pincode,con.country, concat(cu.firstname, ' ' , cu.lastname) createdbyname, concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname FROM ${this.schema}.contact con `;
  query += ` INNER JOIN public.user cu ON cu.Id = con.createdbyid `;
  query += ` INNER JOIN public.user mu ON mu.Id = con.lastmodifiedbyid `;

  if (title) {
    query += ` WHERE con.title LIKE '%${title}%'`;
  }
  query += ` Where con.recordtype = 'Driver'`;


  const result = await sql.query(query);
  return result.rows;
}

// start ---------------------- Added By Pawan ----------------------------------


async function updateById(id, newContact, userid) {
  delete newContact.id;  
  newContact['lastmodifiedbyid'] = userid;

  const query = buildUpdateQuery(id, newContact,this.schema);

  var colValues = Object.keys(newContact).map(function (key) {
    return newContact[key];
  });
  try {
    const result = await sql.query(query, colValues);
    if (result.rowCount > 0) {
      return { "id": id, ...newContact };
    }
    return null;
   
  } catch (error) {
      console.error("Error occurred while executing SQL query:", error);
  }

 

};

// end ---------------------- Added By Pawan ----------------------------------


//......... Count of Staff in Contact ...............
async function getTotalStaffs() {
  let query = `SELECT count(id) totalstaffs FROM ${this.schema}.contact WHERE recordtype='Staff'`;
  const result = await sql.query(query);

  if (result.rows.length > 0)
    return result.rows;

  return null;
};

//......... Count of Parent in Contact ...............
async function getTotalParents() {
  let query = `SELECT count(id) totalparents FROM ${this.schema}.contact WHERE recordtype='Parent'`;
  const result = await sql.query(query);

  if (result.rows.length > 0)
    return result.rows;

  return null;
};



//-------------**code pawan 05 dec 2023 ------------------------
async function deleteContact(id) {
  try {
    const existingReference = await sql.query(
      `SELECT * FROM ${this.schema}.exam_schedule WHERE examinor_id = $1`, [id]);

    if (existingReference.rows.length > 0) {
      throw new Error("Record has reference in another table. Deletion not allowed.");
    }

    const existingTitle = await sql.query(`SELECT * FROM ${this.schema}.contact WHERE id = $1`, [id]);

    if (existingTitle.rows.length === 0) {
      return null;
    }

    const result = await sql.query(`DELETE FROM ${this.schema}.contact WHERE id = $1`, [id]);



    if (result.rowCount > 0) {
      return { message: "Employee deleted successfully!!!" };
    }
    return null;

  } catch (error) {
    throw error;
  }
};

//-------------code pawan 05 dec 2023 **------------------------


function buildUpdateQuery(id, cols,schema) {   // Add by Aamir khan schema  02-05-2024
 
  
  // Setup static beginning of query
  var query = [`UPDATE ${schema}.contact`];    // Add by Aamir khan schema 02-05-2024
  query.push('SET');

  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));

  query.push('WHERE id = \'' + id + '\'');

  return query.join(' ');
}

async function createContact(newContact, userid) {

  newContact.fatherRecordtype = 'Parent_Father';
  newContact.motherRecordtype = 'Parent_Mother';
  newContact.guardianRecordtype = 'Parent_Guardian';
  const resultOfFather = await sql.query(`INSERT INTO ${this.schema}.contact (firstname, lastname,email,phone,profession,qualification,recordtype,createdbyid, lastmodifiedbyid)VALUES ($1, $2, $3, $4, $5, $6, $7,$8,$9) RETURNING *`,
    [newContact.fatherfirstname, newContact.fatherlastname, newContact.fatheremail, newContact.fatherphone, newContact.fatherprofession, newContact.fatherqualification, newContact.fatherRecordtype, userid, userid]);
  if (resultOfFather.rows.length > 0) {

  }
  const resultOfMother = await sql.query(`INSERT INTO ${this.schema}.contact (firstname, lastname,email,phone,profession,qualification,recordtype,createdbyid, lastmodifiedbyid)VALUES ($1, $2, $3, $4, $5, $6, $7,$8,$9) RETURNING *`,
    [newContact.motherfirstname, newContact.motherlastname, newContact.motheremail, newContact.motherphone, newContact.motherprofession, newContact.motherqualification, newContact.motherRecordtype, userid, userid]);
  if (resultOfMother.rows.length > 0) {

  }
  const resultOfGuardian = await sql.query(`INSERT INTO ${this.schema}.contact (firstname, lastname,email,phone,profession,qualification,recordtype,createdbyid, lastmodifiedbyid)VALUES ($1, $2, $3, $4, $5, $6, $7,$8,$9) RETURNING *`,
    [newContact.guardianfirstname, newContact.guardianlastname, newContact.guardianemail, newContact.guardianphone, newContact.guardianprofession, newContact.guardianqualification, newContact.guardianRecordtype, userid, userid]);
  if (resultOfGuardian.rows.length > 0) {
    return { fatherid: resultOfFather.rows[0]['id'], ...newContact, motherid: resultOfMother.rows[0]['id'], ...newContact, guardianid: resultOfGuardian.rows[0]['id'], ...newContact };
  }
  return null;
}
async function duplicateRecord(id, req) {

  console.log('req-rrr->', req);

  let query = `SELECT * FROM ${this.schema}.contact `

  if (id) {
    query += ` WHERE id != '${id}' `;
  }
  else {
   // query += ` WHERE email = '${req?.fatheremail}' OR email = '${req?.motheremail}' OR email = '${req?.guardianemail}'`;
   query += ` Where phone = '${req?.phone}' Or phone = '${req?.phone}' Or phone = '${req?.phone}'`
  }
  ; 
  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  }

  return null;
}
module.exports = {
  findById,
  findParentByStudentParentId,
  updateById,
  findAllParents,
  findAllStaffs,
  create,
  deleteContact,
  getTotalParents,
  getTotalStaffs,
  findAllDrivers,
  getAllTeacherRecords,
  createContact,
  duplicateRecord,
  init
};
