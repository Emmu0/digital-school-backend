const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}



async function CreateAssignemt(newAssignment) {
  const existingAssignment = await sql.query(
    `SELECT * FROM ${this.schema}.assignment WHERE class_id = $1 AND subject_id = $2 AND date = $3`,
    [newAssignment.class_id, newAssignment.subject_id, newAssignment.date]
  );

  if (existingAssignment.rows.length > 0) {
    return null;
  }

  const result = await sql.query(
    `INSERT INTO ${this.schema}.assignment (class_id, subject_id, date, title, description, status) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
    [
      newAssignment.class_id,
      newAssignment.subject_id,
      newAssignment.date,
      newAssignment.title,
      newAssignment.description,
      newAssignment.status
    ]
  );

  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}




async function updateAssignmentById(id, newAssignment) {
  try {
    const existingAssignment = await sql.query(`SELECT * FROM ${this.schema}.assignment WHERE id = $1`, [id]);

    if (existingAssignment.rows.length === 0) {
      return null;
    }

    const duplicateCheck = await sql.query(
      `SELECT * FROM ${this.schema}.assignment WHERE class_id = $1 AND subject_id = $2 AND date = $3 AND id != $4`,
      [newAssignment.class_id, newAssignment.subject_id, newAssignment.date, id]
    );

    if (duplicateCheck.rows.length > 0) {
      return null;
    }

    const result = await sql.query(
      `UPDATE ${this.schema}.assignment SET class_id = $1, subject_id = $2, date = $3, title = $4, description = $5, status = $6 WHERE id = $7 RETURNING *`,
      [newAssignment.class_id, newAssignment.subject_id, newAssignment.date, newAssignment.title, newAssignment.description, newAssignment.status, id]
    );

    if (result.rows.length > 0) {
      return { id, ...newAssignment };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

// async function assignmentsByDates(id, fromdate, todate) {

//   let query = `SELECT *,ass.status as assigmentstatus FROM ${this.schema}.assignment ass
//   INNER JOIN ${this.schema}.class cls ON cls.id = ass.class_id
//   INNER JOIN dwps_ajmer.subject sub ON sub.id = ass.subject_id
//   WHERE ass.class_id = $1`;
//   const params = [id];

//   if (todate === 'null') {
//     query += ` AND ass.date = $2`;
//     params.push(fromdate);
//   } else {
//     query += ` AND ass.date between $2 And $3`;
//     params.push(fromdate, todate);
//   }
//   const result = await sql.query(query, params);

//   if (result.rowCount > 0) {
//     return result.rows;
//   }
//   else {
//     return "No Data Found"
//   }
// }


async function findAllAssignment({ sessionId, class_id, fromdate, todate }) {
  try {
    let query = `
      SELECT t.*, s.year, c.classname AS class, sub.name AS subject_name 
      FROM ${this.schema}.assignment AS t
      LEFT JOIN ${this.schema}.class AS c ON t.class_id = c.id 
      LEFT JOIN ${this.schema}.subject AS sub ON t.subject_id = sub.id
      LEFT JOIN ${this.schema}.session AS s ON s.id = t.session_id
      WHERE 1=1`;

    const values = [];

    query += sessionId ? ` AND t.session_id = $${values.push(sessionId)}` : '';
    query += class_id ? ` AND t.class_id = $${values.push(class_id)}` : '';
    query += fromdate ? ` AND t.date >= $${values.push(fromdate)}` : '';
    query += todate ? ` AND t.date <= $${values.push(todate)}` : '';

    const { rows } = await sql.query(query, values);

    if (!rows || rows.length === 0) {
      return [];
    }

    rows.forEach((row) => {
      const date = new Date(row.date);
      date.setDate(date.getDate() + 1);
      row.date = date.toISOString().split('T')[0];
    });

    return rows;
  } catch (error) {
    console.error("Error fetching assignments:", error);
    throw error;
  }
}

async function deleteAssignment(id) {
  const result = await sql.query(`DELETE FROM ${this.schema}.assignment WHERE id = $1`, [id]);

  if (result.rowCount > 0)
    return "Success"
  return null;
};

module.exports = {
  CreateAssignemt,
  findAllAssignment,
  updateAssignmentById,
  deleteAssignment,

  init
};