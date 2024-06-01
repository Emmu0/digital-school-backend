/**
 * @author : Shakib Khan
 */

const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}

async function duplicateRecord(id, req) {

  let query = `SELECT * FROM ${this.schema}.syllabus `

  if (id) {
    query += ` WHERE id != '${id}' `;
  }
  ;
  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  }

  return null;
}

async function CreateSyllabus(newSyllabus) {
  const result = await sql.query(`INSERT INTO ${this.schema}.syllabus (class_id,section_id,subject_id,description,session_id,isactive)  VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
    [newSyllabus.class_id, newSyllabus.section_id, newSyllabus.subject_id, newSyllabus.description, newSyllabus.session_id, newSyllabus.isactive]);
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
};

async function findAllSyllabus() {
  try {
    const query = `SELECT sy.*, c.classname As class, s.name AS section,su.name AS subject, se.year AS session from ${this.schema}.syllabus AS sy
      LEFT JOIN ${this.schema}.class AS c ON sy.class_id = c.id
      LEFT JOIN ${this.schema}.section AS s ON sy.section_id = s.id
      LEFT JOIN ${this.schema}.subject AS su ON sy.subject_id = su.id
      LEFT JOIN ${this.schema}.session AS se ON sy.session_id = se.id`;
    const { rows } = await sql.query(query);

    if (rows.length > 0) {
      return rows;
    } else {
      return "No Data Found";
    }
  } catch (error) {
    console.error("Error fetching events:", error);
    throw error;
  }
}

async function updateSyllabusById(id, newSyllabus) {
  try {
    ;
    const result = await sql.query(
      `UPDATE ${this.schema}.syllabus SET class_id = $1, section_id = $2, subject_id = $3, description = $4, session_id = $5, isactive = $6 WHERE id = $7 RETURNING *`,
      [newSyllabus.class_id, newSyllabus.section_id, newSyllabus.subject_id, newSyllabus.description, newSyllabus.session_id, newSyllabus.isactive, id]
    );

    if (result.rows.length > 0) {
      return { id, ...newSyllabus };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function deleteSyllabus(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.syllabus WHERE id = $1`, [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};


module.exports = {
  duplicateRecord,
  CreateSyllabus,
  findAllSyllabus,
  updateSyllabusById,
  deleteSyllabus,
  init
};