
// added by the shakib khan 
const sql = require("./db.js");

async function checkDuplicateRole(body) {


  let query = `SELECT id, name, description, status
  FROM role`;

  if (body.name) {
    query += ` WHERE name = '${body.name}' `;

    const result = await sql.query(query);
    if (result.rows.length > 0) {
      return result.rows;
    }
  }

  return null;
}


// Create Role
async function createRole(newRole) {
  delete newRole.id;
  const result = await sql.query("INSERT INTO role (name, status) VALUES ($1, $2) RETURNING *", [newRole.name, newRole.status]);

  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...newRole };
  }

  return null;
}
async function updateRole(id, updatedRole) {
  try {

    const result = await sql.query(
      "UPDATE role SET name = $1, status = $2 WHERE id = $3 RETURNING *",
      [updatedRole.name, updatedRole.status, id]
    );

    if (result.rows.length === 1) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

// Find Role By Id
async function findRoleById(id) {
  const result = await sql.query("SELECT * FROM role WHERE id = $1", [id]);

  if (result.rows.length > 0) {
    return result.rows[0];
  }

  return null;
}

async function getAllRole() {
  const result = await sql.query("select * from role");

  if (result.rows.length > 0) {
    return result.rows;
  }
  return "No Data Found";

}


async function deleteRole(id) {
  try {

    const roleExistance = await sql.query('select id from role_permission where roleid = $1', [id]);
    if (roleExistance.rowCount > 0) {
      return { 'error': 'Record has refrence in another table, Deletion not allowed' };
    }
    const result = await sql.query(
      "DELETE FROM role WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length === 1) {
      return { 'success': result.rows[0] };
    }
    return null;
  } catch (error) {
    throw error;
  }
}
module.exports = { createRole, findRoleById, getAllRole, deleteRole, updateRole, checkDuplicateRole }
