// added by the shakib khan 
const sql = require("./db.js");

async function CheckDuplicatePermission(body) {


    let query = `SELECT id, name, status FROM public.permission`

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
async function createPermission(newPermission) {
    delete newPermission.id;
    const result = await sql.query("INSERT INTO permission (name, status) VALUES ($1, $2) RETURNING *", [newPermission.name, newPermission.status]);

    if (result.rows.length > 0) {
        return { id: result.rows[0].id, ...newPermission };
    }

    return null;
}


async function updatePermission(id, updatedPermission) {
    try {

        const result = await sql.query(
            "UPDATE permission SET name = $1, status = $2 WHERE id = $3 RETURNING *",
            [updatedPermission.name, updatedPermission.status, id]
        );

        if (result.rows.length === 1) {
            return result.rows[0];
        }
        return null;
    } catch (error) {
        throw error;
    }
}


async function deletePermission(id) {
    try {
        const permissionExistance = await sql.query('select id from role_permission where permissionid = $1', [id]);
        if (permissionExistance.rowCount > 0) {
            return { 'error': 'Record has refrence in another table, Deletion not allowed' };
        }
        const result = await sql.query(
            "DELETE FROM permission WHERE id = $1 RETURNING *",
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


module.exports = { createPermission, updatePermission, deletePermission, CheckDuplicatePermission }