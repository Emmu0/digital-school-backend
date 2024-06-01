const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
async function create(newAddmission, userid) {

  delete newAddmission.id;
  const result = await sql.query(
    `INSERT INTO ${this.schema}.student_addmission (studentid,classid ,dateofaddmission,year,parentid,isrte, fee_type,createdbyid, lastmodifiedbyid, session_id)  VALUES ($1, $2, $3,$4,$5,$6,$7,$8, $9, $10) RETURNING *`,
    [newAddmission.studentid, newAddmission.classid, newAddmission.dateofaddmission, newAddmission.year, newAddmission.parentid, newAddmission.isrte, newAddmission.fee_type, userid, userid, newAddmission.session_id]
  );
  if (result.rows.length > 0) {

    return { id: result.rows[0].id, ...newAddmission };
  }
  return null;

}

async function findByStudentAddmissionId(id) {
  let query = `SELECT * from ${this.schema}.student_addmission stadd`;
  query += `INNER JOIN ${this.schema}.contact con on con.id = stadd.studentid`;
  query += `inner join ${this.schema}.class cls on cls.id = stadd.classid`;

  const result = await sql.query(query + ` WHERE stadd.studentid = $1`, [id]);
  if (result.rows.length > 0) return result.rows[0];

  return null;
}

async function findById(id) {
  let query = `SELECT stuAdd.id,stuAdd.isrte,stuAdd.studentid, stuAdd.classid, stuAdd.fee_type,
  stuAdd.dateofaddmission, stuAdd.year, stuAdd.formno,
  stuAdd.parentid, student.isrte,CONCAT(student.firstname, ' ', student.lastname) AS studentname, class.classname,
  CONCAT(contact.firstname, ' ', contact.lastname) AS parentname
  FROM ${this.schema}.student_addmission stuAdd
  INNER JOIN ${this.schema}.student ON stuAdd.studentid = student.id 
  INNER JOIN ${this.schema}.class ON stuAdd.classid = class.id 
  INNER JOIN ${this.schema}.contact ON stuAdd.parentid = contact.id`;

  const result = await sql.query(query + ` WHERE stuAdd.id = $1`, [id]);

  if (result.rows.length > 0)
    return result.rows[0];
  return null;
}
async function findAllRteAddmission() {
  let query = `SELECT stuAdd.id,stuAdd.isrte,stuAdd.studentid, stuAdd.classid, stuAdd.fee_type,
              stuAdd.dateofaddmission, stuAdd.year, stuAdd.formno,
              stuAdd.parentid, student.isrte,CONCAT(student.firstname, ' ', student.lastname) AS studentname, class.classname,
              CONCAT(contact.firstname, ' ', contact.lastname) AS parentname
              FROM ${this.schema}.student_addmission stuAdd
              LEFT JOIN ${this.schema}.student ON stuAdd.studentid = student.id 
              LEFT JOIN ${this.schema}.class ON stuAdd.classid = class.id 
              LEFT JOIN ${this.schema}.contact ON stuAdd.parentid = contact.id`;

  query += ` WHERE stuAdd.isrte = true`;
  const result = await sql.query(query);
  return result.rows;
}

async function findAdmissionByStudentId(student_id) {

  let query = `
  SELECT 
    s.id AS student_id, 
    CONCAT(s.firstname, ' ', s.lastname) AS studentname,
    cls.classname AS current_class,
    sa.id,
    sa.dateofaddmission,
    sa.formno,
    contact.id AS parentId,
    sa.session_id,
    CONCAT(contact.firstname, ' ', contact.lastname) AS parentname,
    fee.type AS fee_type
  FROM 
    dwps_ajmer.student s
  INNER JOIN 
    dwps_ajmer.section sec ON s.section_id = sec.id
  INNER JOIN 
    dwps_ajmer.class cls ON sec.class_id = cls.id
  INNER JOIN 
    dwps_ajmer.student_addmission sa ON sa.studentid = s.id
  LEFT JOIN 
    dwps_ajmer.contact contact ON sa.parentid = contact.id
  LEFT JOIN 
    dwps_ajmer.fee_master fee ON sa.fee_type = fee.id 
  WHERE 
    s.isrte = false`;

  if (student_id !== null) {
    query += ` AND sa.studentid = '${student_id}'`;
  }

  const result = await sql.query(query);
  return result.rows;
}

async function findAll(student_id) {
  console.log('student_id@@=>', student_id);

  let query = `
    SELECT 
      st.*, 
      CONCAT(st.firstname, ' ', st.lastname) AS studentname, 
      TO_CHAR(st.dateofbirth, 'DD-MM-YYYY') AS dateofbirth,
      ad.id AS student_addmission_id, 
      ad.studentid,
      ad.fee_type AS fee_id,
      cls.classname, 
      ad.formno, 
      CONCAT(contact.firstname, ' ', contact.lastname) AS parentname,
      ad.isrte, 
      ad.classid, 
      master.id AS fee_type, 
      master.type AS fee_master_type, 
      ad.dateofaddmission, 
      ad.year, 
      ad.parentid AS parentid,
      CASE 
        WHEN st.category = 'General' THEN COALESCE(master.total_general_fees, 0)
        WHEN st.category = 'Obc' THEN COALESCE(master.total_obc_fees, 0)
        WHEN st.category = 'Sc' THEN COALESCE(master.total_sc_fees, 0)
        WHEN st.category = 'St' THEN COALESCE(master.total_st_fees, 0)
        ELSE 0
      END AS total_fees, 
      COALESCE(pd.dues, 0) AS total_dues,
      sec.name AS section_name,
      CONCAT(vehical.type, ' ', vehical.vehicle_no) AS vehicle_name
    FROM 
      ${this.schema}.student_addmission ad
    INNER JOIN 
      ${this.schema}.class cls ON cls.id = ad.classid
    INNER JOIN 
      ${this.schema}.student st ON st.id = ad.studentid
    LEFT JOIN 
      ${this.schema}.section sec ON sec.id = st.section_id
    LEFT JOIN 
      ${this.schema}.transport vehical ON vehical.id = st.vehicleid
    LEFT JOIN 
      ${this.schema}.fee_master master ON master.id = ad.fee_type
    LEFT JOIN 
      ${this.schema}.fee_deposite depo ON depo.student_addmission_id = ad.id
    LEFT JOIN 
      ${this.schema}.contact contact ON ad.parentid = contact.id
    LEFT JOIN 
      ${this.schema}.pending_amount pd ON pd.student_addmission_id = ad.id
    WHERE 
      cls.status = 'active' AND st.isrte = 'false'`;

  if (student_id !== null && student_id !== 'undefined') {
    query += ` AND ad.studentid = $1`;
  }

  query += `
    GROUP BY 
      st.id, st.dateofbirth, ad.id, master.id, master.type, cls.classname, total_fees, contact.firstname, contact.lastname, ad.formno,
      ad.isrte, ad.classid, ad.fee_type, ad.dateofaddmission, ad.year, ad.parentid, total_dues,
      vehical.type, vehical.vehicle_no, sec.name;`;

  console.log("Generated query:", query);

  try {
    const result = await sql.query(query, student_id !== null && student_id !== 'undefined' ? [student_id] : []);
    return result.rows;
  } catch (error) {
    console.error("Database query error:", error);
    throw error;
  }
}

async function deletestudentaddmision(id) {
  const result = await sql.query(
    `DELETE FROM ${this.schema}.student WHERE id = $1`,
    [id]
  );

  if (result.rowCount > 0) return "Success";
  return null;
}


async function updateById(id, newAddmission, userid) {

  delete newAddmission.id;
  newAddmission["lastmodifiedbyid"] = userid;

  const query = buildUpdateQuery(id, newAddmission, this.schema);

  var colValues = Object.keys(newAddmission).map(function (key) {
    return newAddmission[key];
  });

  const result = await sql.query(query, colValues);

  if (result.rowCount > 0) {
    return { "id": id, ...newAddmission };
  }
  return null;
}

function buildUpdateQuery(id, cols, schema) {

  var query = [`UPDATE ${schema}.student_addmission`];

  query.push('SET');
  var set = [];
  Object.keys(cols).forEach(function (key, i) {
    set.push(key + ' = ($' + (i + 1) + ')');
  });
  query.push(set.join(', '));
  query.push('WHERE id = \'' + id + '\'');
  return query.join(' ');
}
module.exports = {
  findAdmissionByStudentId,
  findById,
  findByStudentAddmissionId,
  updateById,
  findAll,
  create,
  deletestudentaddmision,
  init,
  findAllRteAddmission
};