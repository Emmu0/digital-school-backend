// added by the Shivam Shrivastava
// updated code changes by shahir hussain 22-04-2024

const sql = require("./db.js");

// Create Role
async function createRolePermission(newRolePermission) {

  delete newRolePermission.id;
  const result = await sql.query(

    `INSERT INTO role_permission (name, status,permissionid,roleid,moduleid,read,"create",edit,delete,modify_all,view_all) VALUES ($1, $2,$3, $4,$5, $6,$7, $8, $9,$10,$11) RETURNING *`,
    [
      newRolePermission.name,
      newRolePermission.status,
      newRolePermission.permissionid,
      newRolePermission.roleid,
      newRolePermission.moduleid,
      newRolePermission.read,
      newRolePermission.create,
      newRolePermission.edit,
      newRolePermission.delete,
      newRolePermission.view_all,
      newRolePermission.modify_all,
    ]
  );

  if (result.rows.length > 0) {
    return { id: result.rows[0].id, ...newRolePermission };
  }

  return null;
}

// Find Role By Id
async function findById(id) {
  try {
    const result = await db.oneOrNone(
      `
      SELECT rp.*, r.name AS role, m.name AS module, p.name AS permission
      FROM role_permission AS rp
      LEFT JOIN role AS r ON rp.roleid = r.id
      LEFT JOIN module AS m ON rp.module_id = m.id
      LEFT JOIN permission AS p ON rp.permissionid = p.id
      WHERE rp.id = $1;
      `,
      [id]
    );

    return result;
  } catch (error) {
    console.error('Error executing SQL query:', error);
    throw error;
  }
}

//created by abdul sir 19-04-2024
async function getRolePermissions() {
  let query = 'select * from role_permission';
  const result = await sql.query(query);
  return result.rows;
}

async function getAll() {
  const result =
    await sql.query(` SELECT rp.*, r.name AS role, m.name AS module, p.name AS permission
    FROM role_permission AS rp
    LEFT JOIN role AS r ON rp.roleid = r.id
    LEFT JOIN module AS m ON rp.moduleid = m.id
    LEFT JOIN permission AS p ON rp.permissionid = p.id`);

  if (result.rows.length > 0) {
    return result.rows;
  }
  return null;
}

async function deleteRolePermission(id) {
  try {
    const result = await sql.query(
      "DELETE FROM role_permission WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length === 1) {
      return result.rows[0];
    }
    return null;
  } catch (error) {
    throw error;
  }
}

function removeUnwantedFields(records, fieldsToRemove) {
  return records.map((record) => {
    const filteredRecord = { ...record };
    fieldsToRemove.forEach((field) => delete filteredRecord[field]);

    return filteredRecord;
  });
}

async function insertRecords(records, schema) {

  records = removeUnwantedFields(records, ["id"]);


  const placeholders = records
    .map((record, index) => {
      const keys = Object.keys(record);
      const placeholderString = keys
        .map((key, i) => `$${index * keys.length + i + 1}`)
        .join(", ");
      return `(${placeholderString})`;
    })
    .join(", ");

  const columns = Object.keys(records[0]).join(", ");


  const query = `
      INSERT INTO role_permission (${columns})
      VALUES ${placeholders}
      RETURNING id
    `;


  const values = records.reduce(
    (acc, record) => [...acc, ...Object.values(record)],
    []
  );
  // Execute the query
  const result = await sql.query(query, values);
  return result.rows.map((row) => {

    return row.id;
  });
}

async function updateRecords(records, schema) {

  let ids = [];
  for (const record of records) {
    const { id, ...updateValues } = record; // Exclude id from update values
    const updateColumns = Object.keys(updateValues)
      .map((key, index) => `${key} = $${index + 1}`)
      .join(", ");



    const query = `
                UPDATE role_permission 
                SET ${updateColumns}
                WHERE id = $${Object.keys(updateValues).length + 1}
            `;

    const values = [...Object.values(updateValues), id];

    const result = await sql.query(query, values);
    if (result.rowCount > 0) {
      ids.push(id);
    }
  }

  return ids;
}

async function upsertRecords(records) {

  records = records.map(
    ({
      id,
      moduleid,
      roleid,
      can_create,
      can_read,
      can_edit,
      can_delete,
      view_all,
      modify_all
    }) => ({
      id,
      moduleid,
      roleid,
      can_create,
      can_read,
      can_edit,
      can_delete,
      view_all,
      modify_all
    })
  );

  const { insertRecordList, updateRecordList } = separateRecords(records);
  try {
    let insertedIds = [];
    let updatedIds = [];
    await sql.query("BEGIN");
    if (insertRecordList && insertRecordList.length > 0) {
      insertedIds = await insertRecords(insertRecordList, this.schema);
    }

    if (updateRecordList && updateRecordList.length > 0) {
      updatedIds = await updateRecords(updateRecordList, this.schema);
    }
    await sql.query("COMMIT");

    return { success: true, insertedIds, updatedIds };
  } catch (error) {
    await sql.query("ROLLBACK");
    console.error("Error updating records:", error);
    return { success: false, error: error.message };
  } finally {
    // Release resources if needed
  }
  return false;
}

function separateRecords(records) {
  const insertRecordList = records.filter((record) => record.id === null);
  const updateRecordList = records.filter((record) => record.id !== null);

  return { insertRecordList, updateRecordList };
}





module.exports = {
  createRolePermission,
  findById,
  getAll,
  deleteRolePermission,
  getRolePermissions,
  upsertRecords
};