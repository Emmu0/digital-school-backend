const sql = require("./db.js");
let schema = '';
function init(schema_name){
    this.schema = schema_name;
}

async function createSetting(newSetting) {
  try {
    const result = await sql.query(
      `INSERT INTO ${this.schema}.settings (key, value, createdbyid, lastmodifiedbyid) VALUES ($1, $2, $3, $4) RETURNING *`,
      [newSetting.key, newSetting.value, newSetting.createdbyid, newSetting.lastmodifiedbyid]
    );

    if (result.rows.length > 0) {
      return { id: result.rows[0].id, ...newSetting };
    }
    return null;
  } catch (error) {
    throw error;
  }
}

async function getSettings(key) {
    try {
        let query = `SELECT * FROM ${this.schema}.settings`

        if (key) {
            query += ` WHERE key = '${key}'`
        }

        const result = await sql.query(query);
        if (result.rows.length > 0) {
            return result.rows;
        }
        return null;
    } catch (error) {
        throw error;
    }
}

// update Record
async function updateRecordById(id, settingRecords, userid) {
    settingRecords['lastmodifiedbyid'] = userid;

    const query = buildUpdateQuery(id, settingRecords);
    var colValues = Object.keys(settingRecords).map(function (key) {
        return settingRecords[key];
    });
    const result = await sql.query(query, colValues);
    if (result.rowCount > 0) {
        return { "id": id, ...settingRecords };
    }
    return null;
};

function buildUpdateQuery(id, cols) {
    var query = [`UPDATE ${this.schema}.settings`]; 
    query.push('SET');
    var set = [];
    Object.keys(cols).forEach(function (key, i) {
        set.push(key + ' = ($' + (i + 1) + ')');
    });
    query.push(set.join(', '));
    query.push('WHERE id = \'' + id + '\'');
    return query.join(' ');
}


async function deleteSetting(id) {
    try {
      const existingSetting = await sql.query(`SELECT * FROM ${this.schema}.settings WHERE id = $1`, [id]);
  
      if (existingSetting.rows.length === 0) {
        return null;
      }
  
      const result = await sql.query(`DELETE FROM ${this.schema}.settings WHERE id = $1`, [id]);
  
      if (result.rowCount > 0) {
        return { message: "Setting deleted successfully!!!" };
      }
  
      return null;
    } catch (error) {
      throw error;
    }
  }
  
  module.exports = {
    createSetting,
    getSettings,
    updateRecordById,
    deleteSetting,
    init
  };
