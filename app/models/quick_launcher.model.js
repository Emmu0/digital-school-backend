const db = require("./db");

const sql = require("./db.js");

let schema = "";
function init(schema_name) {
  this.schema = schema_name;
}

async function createQuickLauncher(vl, userid) {
  let result;
  await sql.query(`DELETE FROM dwps_ajmer.quick_launcher`);
  await Promise.all(
    vl.map(async (data, ky) => {
      result = await sql.query(
        `INSERT INTO ${this.schema}.quick_launcher( userid, sub_module_url, icon, status, name) VALUES ($1, $2, $3, $4, $5) RETURNING *`,
        [userid, data?.sub_module_url, data?.icon, data?.status, data?.name]
      );

    })
  );
  if (result?.rows?.length > 0) {
    return result.rows;
  } else {
    return null;
  }
}
async function getAllQuickLauncher(userid) {
  const result = await sql.query(
    `SELECT id, userid, sub_module_url, icon, status,name FROM ${this.schema}.quick_launcher where userid = '${userid}'`
  );

  if (result.rows.length > 0) {
    return result.rows;
  } else {
    return null;
  }
}

async function deleteQuickLaucer(id) {

  const result = await sql.query(
    `DELETE FROM ${this.schema}.quick_launcher where id = '${id}'`
  );
  if (result.rowCount > 0) {
    return result.rowCount;
  } else {
    return null;
  }
}

module.exports = {
  init,
  createQuickLauncher,
  getAllQuickLauncher,
  deleteQuickLaucer,
};
