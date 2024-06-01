const sql = require("./db.js");

let schema = '';
function init(schema_name) {
  this.schema = schema_name;
}
async function createPreviousSchool(preSchool, userid) {


  //delete preSchool.id;
  const result = await sql.query(`INSERT INTO ${this.schema}.previous_schooling(school_name, school_address, class, grade, passed_year,student_id, phone, createdbyid, lastmodifiedbyid) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9) RETURNING *`,
    [preSchool.school_name, preSchool.school_address, preSchool.class, preSchool.grade, preSchool.passed_year, preSchool.student_id, preSchool.phone, userid, userid]);

  if (result.rows.length > 0) {

    return { id: result.rows[0].id, ...preSchool };
  }
  return null;
};

async function duplicateRecord(id, req) {

  let query = `SELECT * FROM ${this.schema}.previous_Schooling `

  if (id) {

    query += ` WHERE id != '${id}' `;
  }
  else {

    query += ` WHERE phone = '${req.student_phone}'`;
  }

  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  }

  return null;
}

async function updateById(id, newStudent, userid) {
  delete newStudent.id;
  newStudent['lastmodifiedbyid'] = userid;
  const query = buildUpdateQuery(id, newStudent);


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
  const result = await sql.query("DELETE FROM student WHERE id = $1", [id]);
  if (result.rowCount > 0)
    return "Success"
  return null;
};

async function findByStudentId(id) {

  let query = "SELECT st.* FROM student st ";
  const result = await sql.query(query + ` WHERE st.id = $1`, [id]);
  if (result.rows.length > 0) {
    return result.rows[0];
  } else {
    return null;
  }
};
async function fetchStudentByParentId(parentId) {

  let query = `SELECT student.*, class.className,class.section FROM student `;
  query += `INNER JOIN class ON student.classid = class.id `;
  query += `WHERE student.parentid = '${parentId}' `;

  const result = await sql.query(query);

  if (result.rows.length > 0) {
    return result.rows;
  } else {
    return null;
  }
};

async function findParentByStudentId(id) {
  let query = "SELECT pr.parentid,* FROM contact pr";

  query += " INNER JOIN contact con ON pr.parentid = con.id";

  const result = await sql.query(query + " WHERE con.id = $1", [id]);


  if (result.rows.length > 0) return result.rows[0];
  else return null;
}

async function findAllStudents(title) {
  let query = "SELECT stu.*, concat(stu.firstname, ' ' , stu.lastname) studentname, ";
  query += "concat(cu.firstname, ' ' , cu.lastname) createdbyname, ";
  query += "concat(mu.firstname, ' ' , mu.lastname) lastmodifiedbyname ";
  query += "FROM public.student stu ";
  query += "INNER JOIN public.user cu ON cu.Id = stu.createdbyid ";
  query += "INNER JOIN public.user mu ON mu.Id = stu.lastmodifiedbyid";

  const result = await sql.query(query);
  return result.rows;
}

//......... Count of Students ...............
async function getTotalStudents() {
  let query =
    "SELECT count(id) totalstudents FROM contact WHERE recordtypeid='Student'";
  const result = await sql.query(query);
  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

function buildUpdateQuery(id, cols) {


  var query = ['UPDATE student'];
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
  createPreviousSchool,
  updateById,
  findByStudentId,
  findParentByStudentId,
  findAllStudents,
  getTotalStudents,
  deleteStudent,
  fetchStudentByParentId,
  init,
  duplicateRecord
};