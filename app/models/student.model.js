const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
// fetch All Records
async function getAllRecords(classId, sectionId) {

  let query = `SELECT 
                  st.id AS student_id,
                  st.classid,
                  st.section_id,
                  CONCAT(st.firstname, ' ', st.lastname) AS student_name,
                  cls.classname,
                  sec.name section_name
                FROM ${this.schema}.student st
                INNER JOIN ${this.schema}.class cls ON cls.id = st.classid 
                INNER JOIN ${this.schema}.section sec ON sec.id = st.section_id `;
  if (classId && sectionId) {
    query += ` WHERE st.classid = '${classId}' AND st.section_id= '${sectionId}' `;

    const result = await sql.query(query);

    if (result.rows.length > 0)
      return result.rows;

  } else {
    return null;

  }

}
async function createStudent(newStudent, userid) {
  delete newStudent.id;
  if (newStudent.isrte === true) {

    const result = await sql.query(`INSERT INTO ${this.schema}.student(firstname, lastname, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, classid, description, permanentcountry, permanentstate, permanentcity,permanentpostalcode, permanentstreet,parentid, vehicleid, isrte,section_id,session_id,createdbyid, lastmodifiedbyid) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27) RETURNING *`,
      [newStudent.firstname, newStudent.lastname, newStudent.religion, newStudent.dateofbirth, newStudent.gender, newStudent.email, newStudent.adharnumber, newStudent.phone, newStudent.pincode, newStudent.street, newStudent.city, newStudent.state, newStudent.country, newStudent.classid, newStudent.description, newStudent.permanentcountry, newStudent.permanentstate, newStudent.permanentcity, newStudent.permanentpostalcode, newStudent.permanentstreet, newStudent.parentId, newStudent.vehicleid, newStudent.isrte, newStudent.section_id,
      newStudent.session_id, userid, userid]);
    if (result.rows.length > 0) {
      return result.rows[0];
    }
  } else {

    const result = await sql.query(`INSERT INTO ${this.schema}.student(firstname, lastname, religion, dateofbirth, gender, email, adharnumber, phone, pincode, street, city, state, country, classid, description, permanentcountry, permanentstate, permanentcity,permanentpostalcode, permanentstreet,parentid, section_id,session_id,vehicleid, createdbyid, lastmodifiedbyid,category) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27) RETURNING *`,
      [newStudent.firstname, newStudent.lastname, newStudent.religion, newStudent.dateofbirth, newStudent.gender, newStudent.email, newStudent.adharnumber, newStudent.phone, newStudent.pincode, newStudent.street, newStudent.city, newStudent.state, newStudent.country, newStudent.classid, newStudent.description, newStudent.permanentcountry, newStudent.permanentstate, newStudent.permanentcity, newStudent.permanentpostalcode, newStudent.permanentstreet, newStudent.parentId,
      newStudent.section_id, newStudent.session_id, newStudent.vehicleid, userid, userid, newStudent.category]);
    if (result.rows.length > 0) {

      return result.rows[0];
    }
  }
  return null;
}

/* Created By Pooja Vaishnav */
async function findByStudentRteId(id) {

  let query = `SELECT stu.id,stu.firstname,stu.lastname,stu.dateofbirth, stu.adharnumber,stu.street,stu.city,stu.state,stu.pincode,stu.phone,stu.email,stu.classid,stu.parentid,stu.religion,stu.gender,stu.country,stu.vehicleid,stu.description,stu.permanentcountry,stu.permanentstate,stu.permanentcity,stu.permanentpostalcode,stu.permanentstreet,stu.isrte,class.classname,CONCAT(contact.firstname, ' ', contact.lastname) AS parentname,student_addmission.dateofaddmission,student_addmission.year,transport.vehicle_no FROM ${this.schema}.student stu `;
  query += ` Full JOIN class ON stu.classid = class.id`;
  query += ` Full JOIN contact ON stu.parentid = contact.id`;
  query += ` Full JOIN transport ON stu.vehicleid = transport.id`;
  query += ` Full JOIN student_addmission ON stu.id = student_addmission.studentid`;

  const result = await sql.query(query + ` WHERE stu.id = $1`, [id]);

  if (result.rows.length > 0) {
    return result.rows[0];
  } else {

    return null;
  }
};

async function fetchStudentByParentId(parentId) {
  console.log('fetchStudentByParentId', parentId)
  let valuesAfterComma = parentId.split(",");

  let inClause = valuesAfterComma.map(id => `'${id}'`).join(', ');
  console.log('inClause@@=>', inClause)
  let query = `
  SELECT student.*, CONCAT(student.firstname, ' ', student.lastname) AS studentname,class.className, section.name,CONCAT(contact.firstname, ' ', contact.lastname) AS parentName,contact.phone as contactPhone
  FROM  ${this.schema}.student
  INNER JOIN ${this.schema}.class ON student.classid = class.id
  INNER JOIN ${this.schema}.section ON student.section_id = section.id
  INNER JOIN ${this.schema}.contact ON student.parentid = contact.id 
  WHERE student.parentid IN (
    ${inClause}
  )`;

  console.log('query=>', query)
  const result = await sql.query(query);
  console.log('resyklyy=>', result.rows)
  if (result.rows.length > 0) {
    return result.rows;

  } else {
    return null;

  }
};

/* Fetch student by class id */
async function fetchStudentByClassId(classid) {

  let query = `SELECT student.* FROM  ${this.schema}.student `;
  query += `WHERE student.classid = '${classid}' `;

  const result = await sql.query(query);

  if (result.rows.length > 0) {
    return result.rows;
  } else {
    return null;
  }
};
async function fetchStudentAddmissionByClassId(classid) {

  const result = await sql.query(`SELECT st.*, TO_CHAR(st.dateofbirth, 'YYYY-MM-DD') as formated_dateofbirth, ad.id as student_addmission_id, cls.classname as classname
  FROM dwps_ajmer.student_addmission ad
  INNER JOIN dwps_ajmer.class cls on cls.id = ad.classid
  INNER JOIN dwps_ajmer.student st on st.id = ad.studentid
  WHERE ad.classid = $1`, [classid]);

  if (result.rows.length > 0) {
    return result.rows;
  } else {
    return null;
  }
};
async function updateById(id, newStudent, userid) {
  delete newStudent.id;
  newStudent['lastmodifiedbyid'] = userid;
  const query = buildUpdateQuery(id, newStudent);

  // Turn req.body into an array of values
  var colValues = Object.keys(newStudent).map(function (key) {
    return newStudent[key];
  });
  const result = await sql.query(query, colValues);
  if (result.rowCount > 0) {
    return { "id": id, ...newStudent };
  }
  return null;
};

async function deleteStudent(id) {
  const result = await sql.query(`DELETE FROM  ${this.schema}.student WHERE id = $1`, [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};

async function findByStudentId(id) {

  let query = `SELECT st.*,  CONCAT(vehical.type,' ',vehical.vehicle_no) as vehicle_name,concat(con.firstname, ' ' , con.lastname) parentname,cls.classname,concat(cu.firstname, ' ' , cu.lastname) createdbyname,
  concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname ,sec.name as section_name,
  concat(st.firstname, ' ' , st.lastname) studentname FROM  ${this.schema}.student st `;

  query += `INNER JOIN public.user cu ON cu.Id = st.createdbyid `;
  query += ` INNER JOIN public.user mu ON mu.Id = st.lastmodifiedbyid `;
  query += ` INNER JOIN ${this.schema}.class cls ON cls.id = st.classid`;
  query += ` INNER JOIN ${this.schema}.section sec ON sec.id = st.section_id`;
  query += ` INNER JOIN ${this.schema}.contact con ON con.id = st.parentid`;
  query += ` INNER JOIN ${this.schema}.transport vehical on vehical.id = st.vehicleid`


  const result = await sql.query(query + ` WHERE st.id = $1`, [id]);
  if (result.rows.length > 0) {
    return result.rows[0];
  } else {
    return null;
  }
};

async function findBySRNumber(srnumber) {

  let query = `SELECT st.*, concat(cu.firstname, ' ' , cu.lastname) createdbyname, concat(mu.firstname, ' ' , mu.lastname) ";
  query += " lastmodifiedbyname ,concat(st.firstname, ' ' , st.lastname) studentname FROM  ${this.schema}.student st ";
  query += " INNER JOIN public.user cu ON cu.Id = st.createdbyid ";
  query += " INNER JOIN public.user mu ON mu.Id = st.lastmodifiedbyid `;


  const result = await sql.query(query + ` WHERE st.srno = $1`, [srnumber]);
  if (result.rows.length > 0) {
    return result.rows[0];
  } else {
    return null;
  }
};


// This is Using to Fetch Students Records
async function findAllStudents(title) {
  let query = `SELECT stu.*, concat(stu.firstname, ' ' , stu.lastname) studentname, `;
  query += `concat(cu.firstname, ' ' , cu.lastname) createdbyname, `;
  query += `concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname `;
  query += `FROM  ${this.schema}.student stu `;
  query += `INNER JOIN public.user cu ON cu.Id = stu.createdbyid `;
  query += `INNER JOIN public.user mu ON mu.Id = stu.lastmodifiedbyid`;
  const result = await sql.query(query);
  return result.rows;
}

//......... Count of Students ...............
async function getTotalStudents() {
  let query =
    `SELECT count(id) totalstudents FROM  ${this.schema}.contact WHERE recordtypeid='Student'`;
  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}
{/***********Added by Shakib : getRteStudents RTE(Module)***********/ }
async function getRteStudents() {
  let query = `SELECT * FROM  ${this.schema}.student WHERE isrte = 'true'`;
  const result = await sql.query(query);
  return result.rows;
}

function buildUpdateQuery(id, cols) {

  // Setup static beginning of query
  var query = [`UPDATE  ${this.schema}.student`];
  query.push('SET');

  // Create another array storing each set command
  // and assigning a number value for parameterized query
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));

  // Add the WHERE statement to look up by id
  query.push('WHERE id = \'' + id + '\'');

  // Return a complete query string
  return query.join(' ');
}
async function findParentByStudentId(id) {
  let query = `SELECT pr.parentid,* FROM  ${this.schema}.contact pr`;
  query += ` INNER JOIN ${this.schema}.contact con ON pr.parentid = con.id`;
  const result = await sql.query(query + " WHERE con.id = $1", [id]);

  if (result.rows.length > 0) return result.rows[0];
  else return null;
}
async function getIsRteStudents() {
  let query = `SELECT * FROM  ${this.schema}.student WHERE isrte = 'true'`;
  const result = await sql.query(query);
  return result.rows;
}
//check duplicate Record
async function duplicateRecord(id, req) {
  let query = `SELECT * FROM  ${this.schema}.student `

  if (id) {

    query += ` WHERE id != '${id}' `;
  }
  else {

    query += ` WHERE email = '${req.email}'`;
  }

  const result = await sql.query(query);
  if (result.rows.length > 0) {

    return result.rows;
  } else {
    return null;
  }
}
module.exports = {
  getAllRecords,
  createStudent,
  updateById,
  findByStudentId,
  findAllStudents,
  getRteStudents,
  getTotalStudents,
  deleteStudent,
  findBySRNumber,
  findParentByStudentId,
  getIsRteStudents,
  duplicateRecord,
  fetchStudentByClassId,
  findByStudentRteId,
  fetchStudentByParentId,
  fetchStudentAddmissionByClassId,
  init
};